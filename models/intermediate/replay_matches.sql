SELECT
  d.id AS replay_id,
  m.scriptName AS replay_map,
  d.engineVersion AS engine,
  d.gameVersion AS game_version,
  (d.startTime AT TIME ZONE 'UTC') AS replay_start_time
FROM {{ source('pgdumps', 'replay_demos') }} AS d
INNER JOIN {{ source('pgdumps', 'replay_maps') }} AS m
  ON d.mapId = m.id
WHERE d.gameEndedNormally
