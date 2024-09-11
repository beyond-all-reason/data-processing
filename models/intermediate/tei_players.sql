SELECT
  match_id,
  team_id,
  user_id,
  party_id,
  left_after,
  old_skill,
  old_uncertainty,
  new_skill,
  new_uncertainty
FROM (SELECT match_id FROM {{ ref("tei_matches") }})
INNER JOIN {{ ref("tei_match_memberships") }}
  USING (match_id)
FULL OUTER JOIN {{ ref("tei_match_ratings") }}
  USING (match_id, user_id)
ORDER BY
  match_id, team_id, user_id
