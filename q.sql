WITH
  games AS (
    SELECT
      match_id,
      replay_id,
      replay_start_time,
      start_time AS tei_start_time,
      coalesce(replay_start_time, tei_start_time) AS any_start_time
    FROM tei_matches
    FULL OUTER JOIN tei_replay_map
      USING (match_id)
    FULL OUTER JOIN replay_matches
      USING (replay_id)
    WHERE any_start_time > '2022-08-01'
  )
SELECT
  time_bucket(INTERVAL '1 month', any_start_time)::DATE AS t,
  count(match_id) AS tei,
  count(replay_id) AS replay,
  count(*) FILTER (match_id IS NOT NULL AND replay_id IS NOT NULL) AS total_m, -- noqa
  count(*) total,
  round(100 * total_m / total, 1) as matched
FROM games
GROUP BY t
ORDER BY t

-- SELECT
--   m,
--   round((not_found / total) * 100, 2) AS "%",
--   not_found,
--   total
-- FROM (
--   SELECT
--     strftime('%Y %m', replay_start_time) AS m,
--     count(*) AS not_found
--   FROM replay_matches
--   LEFT JOIN tei_replay_map USING (replay_id)
--   WHERE match_id IS null
--   GROUP BY 1
--   ORDER BY 1
-- )
-- JOIN (SELECT
--   strftime('%Y %m', replay_start_time) AS m,
--   count(*) AS total
-- FROM replay_matches LEFT JOIN tei_replay_map USING (replay_id) GROUP BY 1 ORDER BY 1) USING (m)
-- WHERE m > '2022 08'
-- ORDER BY m;
