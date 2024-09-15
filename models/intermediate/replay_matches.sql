WITH
  wt AS (
    SELECT
      demoId AS replay_id,
      -- *1000 to put them in a different "namespace"
      id * 1000 AS winning_team
    FROM {{ source('pgdumps', 'replay_ally_teams') }}
    WHERE winningTeam
  )
SELECT
  d.id AS replay_id,
  m.scriptName AS replay_map,
  d.engineVersion AS engine,
  d.gameVersion AS game_version,
  wt.winning_team AS replay_winning_team,
  (d.startTime AT TIME ZONE 'UTC') AS replay_start_time
FROM {{ source('pgdumps', 'replay_demos') }} AS d
INNER JOIN {{ source('pgdumps', 'replay_maps') }} AS m
  ON d.mapId = m.id
LEFT JOIN wt
  ON d.id = wt.replay_id
WHERE d.gameEndedNormally
