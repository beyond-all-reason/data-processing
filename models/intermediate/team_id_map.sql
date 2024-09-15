WITH
  base AS (
    SELECT
      match_id,
      user_id,
      team_id,
      replay_team_id
    FROM {{ ref("tei_players") }}
    LEFT JOIN {{ ref("tei_replay_map") }}
      USING (match_id)
    FULL OUTER JOIN {{ ref("replay_players") }}
      USING (replay_id, user_id)
    WHERE match_id IS NOT NULL
  )
SELECT *
FROM base
