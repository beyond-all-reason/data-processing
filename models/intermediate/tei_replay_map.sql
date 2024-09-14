WITH
  replays_minmax_user AS (
    SELECT
      replay_id,
      min(user_id) AS min_user_id,
      max(user_id) AS max_user_id
    FROM {{ ref("replay_players") }}
    GROUP BY replay_id
  ),
  replays AS (
    SELECT
      replay_id,
      replay_map,
      min_user_id,
      max_user_id,
      replay_start_time + INTERVAL 30 SECOND AS replay_start_time_shifted
    FROM {{ ref("replay_matches") }}
    INNER JOIN replays_minmax_user
      USING (replay_id)
  ),
  matches_minmax_user AS (
    SELECT
      match_id,
      min(user_id) AS min_user_id,
      max(user_id) AS max_user_id
    FROM {{ ref("tei_players") }}
    GROUP BY match_id
  ),
  matches AS (
    SELECT
      match_id,
      map,
      min_user_id,
      max_user_id,
      start_time
    FROM {{ ref("tei_matches") }}
    INNER JOIN matches_minmax_user
      USING (match_id)
    WHERE is_public
  ),
  -- for whatever reason,
  --   AND (m.max_user_id = r.max_user_id OR m.min_user_id = r.min_user_id)
  -- returns *less* results, not more, so we do it like below, maybe regression
  -- of https://github.com/duckdb/duckdb/issues/9183 ? Need to repro and file
  -- a bug...
  min_match AS (
    SELECT
      m.match_id,
      r.replay_id AS replay_id_min_match
    FROM matches AS m
    ASOF JOIN replays AS r
      ON m.map = r.replay_map
        AND m.min_user_id = r.min_user_id
        AND m.start_time <= r.replay_start_time_shifted
    WHERE r.replay_start_time_shifted - m.start_time < INTERVAL 60 SECOND
  ),
  max_match AS (
    SELECT
      m.match_id,
      r.replay_id AS replay_id_max_match
    FROM matches AS m
    ASOF JOIN replays AS r
      ON m.map = r.replay_map
        AND m.max_user_id = r.max_user_id
        AND m.start_time <= r.replay_start_time_shifted
    WHERE r.replay_start_time_shifted - m.start_time < INTERVAL 60 SECOND
  )
SELECT
  m.match_id,
  replay_id_min_match,
  replay_id_max_match,
  coalesce(replay_id_min_match, replay_id_max_match) AS replay_id
FROM matches AS m
LEFT JOIN min_match
  USING (match_id)
LEFT JOIN max_match
  USING (match_id)
WHERE replay_id_min_match IS NOT NULL
  OR replay_id_max_match IS NOT NULL
