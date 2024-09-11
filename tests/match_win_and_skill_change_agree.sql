WITH
  ranked_matches AS (
    SELECT
      match_id,
      replay_id,
      winning_team
    FROM {{ ref("matches") }} WHERE is_ranked
  ),
  teams AS (
    SELECT
      match_id,
      team_id,
      sum(new_skill - old_skill) > 0 AS won
    FROM {{ ref("match_players") }}
    GROUP BY match_id, team_id
  ),
  winning_team AS (
    SELECT
      match_id,
      any_value(team_id) AS computed_winning_team,
      count(*) AS num_winning_teams
    FROM teams
    WHERE won
    GROUP BY match_id
  )
SELECT
  match_id,
  replay_id,
  winning_team,
  computed_winning_team,
  num_winning_teams
FROM ranked_matches
LEFT JOIN winning_team
  USING (match_id)
WHERE winning_team != computed_winning_team
  OR num_winning_teams > 1
ORDER BY match_id DESC
