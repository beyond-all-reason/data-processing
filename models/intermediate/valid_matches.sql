WITH
  -- removes ~4500 matches that have some entries with tema_id=null
  null_team_id AS (
    SELECT
      match_id,
      bool_or(team_id IS null) AS has_null_team_id
    FROM {{ ref("tei_match_players") }}
    GROUP BY match_id
  ),
  -- removes ~75 matches on top of the null_team_id table
  correct_team_count AS (
    WITH
      current_team_ids AS (
        SELECT
          match_id,
          team_id
        FROM {{ ref("tei_match_players") }}
        WHERE team_id IS NOT null
        GROUP BY match_id, team_id
      ),
      real_team_count AS (
        SELECT
          match_id,
          count(*) AS cumputed_team_count
        FROM current_team_ids
        GROUP BY match_id
      )
    SELECT
      match_id,
      coalesce(cumputed_team_count, -1) = team_count AS has_matching_team_count
    FROM {{ ref("tei_matches") }}
    LEFT JOIN real_team_count
      USING (match_id)
  ),
  -- Deleting a teiserver account removes all of its memberships and rating
  -- logs, so the user silently disappears from all past matches. Replays still
  -- have them, so we can detect it there.
  deleted_player AS (
    SELECT
      replay_id,
      bool_or(rp.user_id IS NOT null AND tp.user_id IS null)
        AS has_deleted_player
    FROM {{ ref("replay_players") }} AS rp
    LEFT JOIN {{ ref("tei_players") }} AS tp
      USING (user_id)
    GROUP BY replay_id
  )
SELECT
  match_id,
  has_matching_team_count,
  -- Not part of is_valid: such matches are still exported, just flagged.
  has_deleted_player,
  -- We need coalesce because some matches (e.g. 9078785) have no players
  -- at all and left join makes it NULL.
  coalesce(has_null_team_id, false) AS has_null_team_id,
  has_matching_team_count AND NOT coalesce(has_null_team_id, false) AS is_valid
FROM {{ ref("tei_matches") }}
LEFT JOIN null_team_id
  USING (match_id)
LEFT JOIN correct_team_count
  USING (match_id)
LEFT JOIN {{ ref("tei_replay_map") }}
  USING (match_id)
LEFT JOIN deleted_player
  USING (replay_id)
