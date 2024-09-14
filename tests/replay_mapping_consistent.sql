SELECT *
FROM {{ ref('rei_replay_map') }}
WHERE replay_id_min_match != replay_id_max_match
