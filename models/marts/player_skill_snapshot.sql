{{ config(location='data_export/player_skill_snapshot.parquet') }}

WITH
  matches AS (
    SELECT
      match_id,
      start_time,
      game_type,
      lower(game_type) AS game_type_l
    FROM {{ ref("matches") }}
    WHERE is_ranked = true
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
      m.start_time,
      mp.user_id,
      p.name,
      p.countryCode,
      mp.new_skill,
      mp.new_uncertainty,
      CASE
        WHEN m.game_type_l LIKE '%duel%' THEN 'duel'
        WHEN m.game_type_l LIKE '%ffa%' THEN 'ffa'
        WHEN m.game_type_l LIKE '%large%' THEN 'large'
        WHEN m.game_type_l LIKE '%small%' THEN 'small'
      END AS game_type
    FROM {{ ref("match_players") }} AS mp
    INNER JOIN matches AS m ON mp.match_id = m.match_id
    INNER JOIN players AS p ON mp.user_id = p.user_id
  ),
  aggregated AS (
    SELECT
      user_id,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'duel') AS duelSkill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'duel') AS duelSkillUn,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'ffa') AS ffaSkill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'ffa') AS ffaSkillUn,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'large') AS teamSkill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'large') AS teamSkillUn,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'duel') AS lastDuel,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'ffa') AS lastFFA,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'large') AS lastTeam,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'small') AS lastSmallTeam,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'small') AS smallTeamSkill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'small') AS smallTeamSkillUn
    FROM joined
    WHERE game_type IS NOT null
    GROUP BY user_id
  )
SELECT
  a.user_id AS id,
  p.name,
  a.duelSkill,
  a.duelSkillUn,
  a.ffaSkill,
  a.ffaSkillUn,
  a.teamSkill,
  a.teamSkillUn,
  a.lastDuel,
  a.lastFFA,
  a.lastTeam,
  p.countryCode,
  a.lastSmallTeam,
  a.smallTeamSkill,
  a.smallTeamSkillUn
FROM aggregated AS a
INNER JOIN players AS p ON a.user_id = p.user_id
ORDER BY a.user_id
