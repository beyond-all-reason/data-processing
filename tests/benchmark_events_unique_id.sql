SELECT
  id,
  is_anon,
  count(*) AS n
FROM {{ ref('benchmark_events') }}
GROUP BY id, is_anon
HAVING count(*) > 1
