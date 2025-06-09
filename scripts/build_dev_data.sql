-- A simple standalone sql to build the dev sample data from prod for quick
-- smoke testing and quick local development.
--
-- This is supposed to be used fully manually bu a developer that has access
-- to prod data.
--
-- duckdb < scripts/build_dev_data.sql

-- disable references.special_chars and ambiguous.column_count checks
-- noqa: disable=RF05,AM04

CREATE TEMP TABLE sample_matches AS
SELECT DISTINCT unnest(list_value(
  -- all game types:
  --   select count(*), game_type, any_value(match_id)
  --   from 'data_export/matches.parquet'
  --   group by game_type;
  3203518, -- Team ffa
  3199974, -- Raptors
  3199805, -- Duel
  3199822, -- Bots
  3199897, -- FFA
  3199798, -- Large team (also has a party)
  3199823, -- Small team (and ranked)
  3201388, -- Scavengers
  87897, -- Team

  -- ranked/unranked
  --   select count(*), is_ranked, any_value(match_id)
  --   from 'data_export/matches.parquet'
  --   where game_type = 'Small Team' group by is_ranked;
  3199855, -- not ranked
  3199823, -- ranked

  -- entries we want filtered out
  3345042, -- no winning team
  282737, -- null team ids
  2310477 -- not matching team count
)) AS match_id;

CREATE TEMP TABLE sample_replays AS SELECT DISTINCT unnest(list_value(
  -- Replays for above valid ones, dropping one
  'b852a96656af200372af5920b8e68370',
  '7354a9661c8e557741e2bc2ec1242b7a',
  'bd53a966b810a086a0f1ca3bd167f9f9',
  '1154a966f056a12d9715244dc5b3c753',
  '5055a966ab2815c95098d93eae22a660',
  '545ba9665b8ef7650292ae0ec16cfc76',
  'd2c1a966ccc44ce05a8a3c6aade8ebb4',
  'ce89aa66b9fa9012d9a5f977b3c0f137'
)) AS replay_id;

CREATE TEMP TABLE teiserver_battle_matches AS
SELECT
  tbm.* EXCLUDE (data),
  -- anonymize IPs
  regexp_replace(data, '\d+\.\d+\.\d+.\d+', '0.0.0.0', 'g') AS data -- noqa: RF04
FROM 'data_source/prod/teiserver_battle_matches.parquet' AS tbm
INNER JOIN sample_matches ON id = match_id
ORDER BY id;


CREATE TEMP TABLE teiserver_battle_match_memberships AS
SELECT tbmm.*
FROM 'data_source/prod/teiserver_battle_match_memberships.parquet' AS tbmm
INNER JOIN sample_matches USING (match_id)
ORDER BY match_id, user_id;

CREATE TEMP TABLE teiserver_game_rating_logs AS
SELECT *
FROM 'data_source/prod/teiserver_game_rating_logs.parquet'
INNER JOIN sample_matches USING (match_id)
ORDER BY id;

CREATE TEMP TABLE teiserver_users AS
WITH
  users AS (
    SELECT DISTINCT user_id FROM teiserver_battle_match_memberships
    FULL OUTER JOIN teiserver_game_rating_logs USING (user_id)
  )
SELECT
  -- there is ofc many more columns, we just pull in minimal set because it's
  -- sensitive data
  id,
  name
FROM users AS u
INNER JOIN 'data_source/prod/teiserver_users.parquet' AS tu
  ON u.user_id = tu.id
ORDER BY id;

CREATE TEMP TABLE teiserver_user_stats AS
SELECT
  user_id,
  json_object('country', json_extract(data, 'country'))::VARCHAR AS data -- noqa: RF04
FROM 'data_source/prod/teiserver_user_stats.parquet' AS tus
INNER JOIN teiserver_users AS tu
  ON tus.user_id = tu.id
ORDER BY user_id;

CREATE TEMP TABLE replay_demos AS
SELECT rd.*
FROM 'data_source/prod/replay_demos.parquet' AS rd
INNER JOIN sample_replays ON rd.id = replay_id
ORDER BY rd.id;

CREATE TEMP TABLE replay_ally_teams AS
SELECT allyteams.*
FROM 'data_source/prod/replay_ally_teams.parquet' AS allyteams
INNER JOIN sample_replays ON allyteams.demoId = replay_id
ORDER BY allyteams.id;

CREATE TEMP TABLE replay_maps AS
WITH rd AS (SELECT DISTINCT mapId FROM replay_demos)
SELECT m.*
FROM 'data_source/prod/replay_maps.parquet' AS m
INNER JOIN rd ON m.id = rd.mapId
ORDER BY m.id;

CREATE TEMP TABLE replay_players AS
SELECT p.*
FROM 'data_source/prod/replay_players.parquet' AS p
INNER JOIN replay_ally_teams AS allyteams ON p.allyTeamId = allyteams.id
ORDER BY p.id;

-- noqa: disable=all
copy teiserver_battle_matches to 'data_source/dev/teiserver_battle_matches.parquet' (format parquet, codec zstd);
copy teiserver_battle_match_memberships to 'data_source/dev/teiserver_battle_match_memberships.parquet' (format parquet, codec zstd);
copy teiserver_game_rating_logs to 'data_source/dev/teiserver_game_rating_logs.parquet' (format parquet, codec zstd);
copy teiserver_users to 'data_source/dev/teiserver_users.parquet' (format parquet, codec zstd);
copy teiserver_user_stats to 'data_source/dev/teiserver_user_stats.parquet' (format parquet, codec zstd);
copy replay_demos to 'data_source/dev/replay_demos.parquet' (format parquet, codec zstd);
copy replay_ally_teams to 'data_source/dev/replay_ally_teams.parquet' (format parquet, codec zstd);
copy replay_maps to 'data_source/dev/replay_maps.parquet' (format parquet, codec zstd);
copy replay_players to 'data_source/dev/replay_players.parquet' (format parquet, codec zstd);
