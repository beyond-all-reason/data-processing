-- We have do do deduplication of entrieS, group by match_id and user_id due to
-- teiserver bug: https://github.com/beyond-all-reason/teiserver/issues/433
-- To resolve, we figure out whatever player won/lost and pick the top and
-- bottom skill values respectively. For example if they won, it's going to be
-- multiple skill increases and we merge them into one large one.
WITH
  ratings AS (
    SELECT
      match_id,
      user_id,
      -- Floats are fine, we really don't need to store double precision,
      -- it only blows up the output file size
      ((value::JSON).skill::DOUBLE - (value::JSON).skill_change::DOUBLE)::FLOAT AS old_skill,
      ((value::JSON).uncertainty::DOUBLE - (value::JSON).uncertainty_change::DOUBLE)::FLOAT
        AS old_uncertainty,
      (value::JSON).skill::FLOAT AS new_skill,
      (value::JSON).uncertainty::FLOAT AS new_uncertainty,
      CASE WHEN (value::JSON).skill_change::DOUBLE > 0 THEN 1 ELSE -1 END AS win_ord
    FROM {{ ref("tei_matches") }}
    INNER JOIN {{ source('pgdumps', 'teiserver_game_rating_logs') }}
      USING (match_id)
  )
SELECT
  match_id,
  user_id,
  first(
    old_skill
    ORDER BY old_skill * win_ord
  ) AS old_skill,
  first(
    old_uncertainty
    ORDER BY old_skill * win_ord
  ) AS old_uncertainty,
  last(
    new_skill
    ORDER BY old_skill * win_ord
  ) AS new_skill,
  last(
    new_uncertainty
    ORDER BY old_skill * win_ord
  ) AS new_uncertainty,
  abs(sum(win_ord)) = count(*) AS all_win_same -- Just for testing
FROM ratings
GROUP BY match_id, user_id
