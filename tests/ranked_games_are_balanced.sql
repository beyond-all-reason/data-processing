WITH
  teams AS (
    SELECT
      match_id,
      team_id,
      count(*) AS player_count
    FROM {{ ref('match_players') }}
    GROUP BY match_id, team_id
  )
SELECT
  match_id,
  any_value(replay_id) AS replay_id,
  any_value(start_time) AS start_time
FROM {{ ref('matches') }}
INNER JOIN teams
  USING (match_id)
-- Before this date, there are a bunch of players that were purged from the
-- games for some reason :((, maybe we can somehow fix this data using replays
-- in the future...
WHERE is_ranked AND start_time > '2023-05-16'
  -- Players who deleted their accounts are missing from matches. We can only
  -- detect it with a replay, so we also skip matches without one.
  AND NOT coalesce(has_deleted_player, true)
GROUP BY match_id
HAVING count(DISTINCT player_count) > 1
ORDER BY match_id DESC
