WITH
  replays_min_user AS (
    SELECT
      replay_id,
      min(user_id) AS min_user_id
    FROM {{ ref("replay_players") }}
    GROUP BY replay_id
  ),
  replays AS (
    SELECT
      replay_id,
      replay_map,
      min_user_id,
      replay_start_time + INTERVAL 30 SECOND AS replay_start_time_shifted
    FROM {{ ref("replay_matches") }}
    INNER JOIN replays_min_user
      USING (replay_id)
  ),
  matches_min_user AS (
    SELECT
      match_id,
      min(user_id) AS min_user_id
    FROM {{ ref("tei_players") }}
    GROUP BY match_id
  ),
  matches AS (
    SELECT
      match_id,
      map,
      min_user_id,
      start_time
    FROM {{ ref("tei_matches") }}
    INNER JOIN matches_min_user
      USING (match_id)
    WHERE is_public
  )
SELECT
  m.match_id,
  r.replay_id
FROM matches AS m
ASOF JOIN replays AS r
  ON m.map = r.replay_map
    AND m.min_user_id = r.min_user_id
    AND m.start_time <= r.replay_start_time_shifted
WHERE r.replay_start_time_shifted - m.start_time < INTERVAL 60 SECOND
