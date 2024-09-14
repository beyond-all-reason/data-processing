SELECT
  allayteams.demoId AS replay_id,
  p.userId AS user_id,
  CASE p.faction
    WHEN 'unknown' THEN 'Unknown'
    WHEN '' THEN 'Unknown'
    ELSE p.faction
  END AS faction
FROM {{ source('pgdumps', 'replay_ally_teams') }} AS allayteams
INNER JOIN {{ source('pgdumps', 'replay_players') }} AS p
  ON allayteams.id = p.allyTeamId
INNER JOIN {{ ref('replay_matches') }} AS rm
  ON allayteams.demoId = rm.replay_id
