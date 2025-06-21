{{ config(location='data_export/players.parquet') }}

WITH
  active_players AS (
    SELECT DISTINCT user_id
    FROM {{ ref("match_players") }}
  )
SELECT
  user_id,
  name,
  country
FROM active_players
INNER JOIN {{ ref("tei_players") }}
  USING (user_id)
ORDER BY user_id
