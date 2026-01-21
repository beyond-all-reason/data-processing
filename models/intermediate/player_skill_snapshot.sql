{{ config(location='data_export/player_skill_snapshot.parquet') }}

WITH
  matches AS (
    SELECT
      match_id,
      start_time,
      lower(game_type) AS game_type_l
    FROM {{ ref("matches") }}
    WHERE is_ranked = true
  ),
  match_players AS (
    SELECT
      match_id,
      user_id,
      new_skill,
      new_uncertainty
    FROM {{ ref("match_players") }}
  ),
  players AS (
    SELECT
      user_id,
      name,
      country AS countryCode
    FROM {{ ref("players") }}
  ),
  joined AS (
    SELECT
      mp.user_id,
      p.name,
      p.countryCode,
      m.start_time,
      CASE
        WHEN m.game_type_l LIKE '%duel%' THEN 'duel'
        WHEN m.game_type_l LIKE '%ffa%' THEN 'ffa'
        WHEN m.game_type_l LIKE '%large%' THEN 'large'
        WHEN m.game_type_l LIKE '%small%' THEN 'small'
        ELSE NULL
      END AS game_type,
      mp.new_skill,
      mp.new_uncertainty
    FROM match_players mp
    JOIN matches m USING (match_id)
    JOIN players p USING (user_id)
  )
SELECT
  user_id AS id,
  name,
  arg_max(new_skill, start_time) FILTER (WHERE game_type = 'duel')  AS duelSkill,
  arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'duel') AS duelSkillUn,
  arg_max(new_skill, start_time) FILTER (WHERE game_type = 'ffa')   AS ffaSkill,
  arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'ffa')  AS ffaSkillUn,
  arg_max(new_skill, start_time) FILTER (WHERE game_type = 'large') AS teamSkill,
  arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'large') AS teamSkillUn,
  arg_max(start_time, start_time) FILTER (WHERE game_type = 'duel')  AS lastDuel,
  arg_max(start_time, start_time) FILTER (WHERE game_type = 'ffa')   AS lastFFA,
  arg_max(start_time, start_time) FILTER (WHERE game_type = 'large') AS lastTeam,
  countryCode,
  arg_max(start_time, start_time) FILTER (WHERE game_type = 'small') AS lastSmallTeam,
  arg_max(new_skill, start_time) FILTER (WHERE game_type = 'small')  AS smallTeamSkill,
  arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'small') AS smallTeamSkillUn
FROM joined
WHERE game_type IS NOT NULL
GROUP BY user_id, name, countryCode
ORDER BY user_id
