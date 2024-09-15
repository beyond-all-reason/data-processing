SELECT
  match_id,
  start_time,
  map,
  team_count,
  game_type,
  newtid.new_team_id AS winning_team,
  game_duration,
  is_ranked,
  replay_id,
  engine,
  game_version,
  is_public
FROM {{ ref("tei_matches") }} AS tm
LEFT JOIN {{ ref("tei_replay_map") }}
  USING (match_id)
LEFT JOIN {{ ref("tei_players_new_team_id") }} AS newtid
  ON tm.match_id = newtid.match_id
    AND tm.winning_team = newtid.team_id
LEFT JOIN {{ ref("replay_matches") }}
  USING (replay_id)
ORDER BY match_id
