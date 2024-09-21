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
  )
SELECT
  match_id,
  has_matching_team_count,
  has_null_team_id,
  has_matching_team_count AND NOT has_null_team_id AS is_valid
FROM {{ ref("tei_matches") }}
LEFT JOIN null_team_id
  USING (match_id)
LEFT JOIN correct_team_count
  USING (match_id)
