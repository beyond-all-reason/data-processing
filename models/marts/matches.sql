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
  game_type,
  winning_team,
  game_duration,
  is_ranked,
  replay_id,
  engine,
  game_version,
  is_public
FROM {{ ref("out_matches") }}
INNER JOIN valid
  USING (match_id)
ORDER BY match_id
