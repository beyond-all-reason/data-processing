WITH
  teams AS (
    SELECT
      match_id,
      team_id
    FROM {{ ref("tei_match_players") }}
    GROUP BY match_id, team_id
  )
SELECT
  match_id,
  team_id,
  (row_number() OVER (PARTITION BY match_id ORDER BY team_id ASC)) - 1 AS new_team_id
FROM teams
