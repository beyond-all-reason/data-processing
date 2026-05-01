SELECT id, is_anon, COUNT(*) AS n
FROM {{ ref('benchmark_events') }}
GROUP BY id, is_anon
HAVING COUNT(*) > 1
