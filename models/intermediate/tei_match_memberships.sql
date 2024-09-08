SELECT
  match_id,
  user_id,
  team_id,
  bmm.party_id,
  win,
  left_after
FROM {{ ref("tei_matches") }}
INNER JOIN {{ source('pgdumps', 'teiserver_battle_match_memberships') }} AS bmm
  USING (match_id)
