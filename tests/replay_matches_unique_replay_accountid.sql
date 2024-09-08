-- Test that all replay_id,user_id shows up only once. There are examples from
-- 2021 where it's not true, so... we just pick all after 2022, as teiserver
-- match logs are from 2022-04-06 onwards anyway...

SELECT
  replay_id,
  user_id
FROM {{ ref("replay_players") }}
INNER JOIN {{ ref("replay_matches") }}
  USING (replay_id)
WHERE user_id IS NOT null
  AND replay_start_time > '2022-01-01'::TIMESTAMP
GROUP BY replay_id, user_id
HAVING count(*) > 1
