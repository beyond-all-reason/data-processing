{{ config(location='data_export_internal/benchmark_events.parquet') }}

SELECT
  id,
  timestamp,
  value,
  is_anon
FROM {{ source('pgdumps', 'teiserver_benchmark_events') }}
