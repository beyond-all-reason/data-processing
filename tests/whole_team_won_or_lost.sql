WITH
  teams AS (
    SELECT
      match_id,
      team_id,
      bool_and(new_skill - old_skill >= 0) AS team_won,
      bool_and(new_skill - old_skill <= 0) AS team_lost
    FROM {{ ref("match_players") }}
    GROUP BY match_id, team_id
  )
SELECT
  match_id,
  any_value(replay_id) AS replay_id,
  array_agg(team_id) AS teams
FROM {{ ref("matches") }}
INNER JOIN teams
  USING (match_id)
WHERE NOT team_won AND NOT team_lost
GROUP BY match_id
ORDER BY match_id DESC
