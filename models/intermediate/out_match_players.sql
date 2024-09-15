SELECT
  match_id,
  new_team_id AS team_id,
  user_id,
  party_id,
  left_after,
  new_skill,
  new_uncertainty,
  faction,
  coalesce(old_skill, replay_old_skill) AS old_skill,
  coalesce(old_uncertainty, replay_old_uncertainty) AS old_uncertainty
FROM {{ ref("tei_players") }}
LEFT JOIN {{ ref("tei_replay_map") }}
  USING (match_id)
FULL OUTER JOIN {{ ref("replay_players") }}
  USING (replay_id, user_id)
LEFT JOIN {{ ref("tei_players_new_team_id") }}
  USING (match_id, team_id)
ORDER BY
  match_id, team_id, user_id
