{{ config(location='data_export/match_players.parquet') }}

WITH
  valid AS (
    SELECT match_id FROM {{ ref("valid_matches") }} WHERE is_valid
  )
SELECT
  match_id,
  new_team_id AS team_id,
  user_id,
  party_id,
  left_after,
  old_skill,
  old_uncertainty,
  new_skill,
  new_uncertainty,
  faction
FROM {{ ref("tei_match_players") }}
INNER JOIN valid
  USING (match_id)
LEFT JOIN {{ ref("tei_replay_map") }}
  USING (match_id)
LEFT JOIN {{ ref("replay_players") }}
  USING (replay_id, user_id)
LEFT JOIN {{ ref("tei_match_players_new_team_id") }}
  USING (match_id, team_id)
ORDER BY
  match_id, team_id, user_id
