SELECT *
FROM {{ ref('tei_replay_map') }}
WHERE replay_id_min_match != replay_id_max_match
