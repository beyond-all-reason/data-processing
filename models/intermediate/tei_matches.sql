SELECT
  id AS match_id,
  started AS start_time,
  map,
  team_count,
  game_type,
  winning_team,
  game_duration,
  processed,
  rating_type_id IS NOT null AS is_ranked,
  NOT passworded AS is_public
FROM {{ source('pgdumps', 'teiserver_battle_matches') }}
WHERE start_time IS NOT null
  AND is_public -- at the moment, only public matches
ORDER BY
  id
