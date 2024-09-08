{{ config(location='data_export/matches.parquet') }}

WITH
  valid AS (
    SELECT match_id FROM {{ ref("valid_matches") }} WHERE is_valid
  )
SELECT
  match_id,
  start_time,
  map,
  team_count,
  team_size,
  game_type,
  winning_team,
  game_duration,
  is_ranked,
  replay_id,
  engine,
  game_version,
  is_public
FROM {{ ref("tei_matches") }}
INNER JOIN valid
  USING (match_id)
LEFT JOIN {{ ref("tei_replay_map") }}
  USING (match_id)
LEFT JOIN {{ ref("replay_matches") }}
  USING (replay_id)
ORDER BY match_id
