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
      country AS country_code
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
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'duel') AS duel_skill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'duel') AS duel_skill_un,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'ffa') AS ffa_skill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'ffa') AS ffa_skill_un,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'large') AS team_skill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'large') AS team_skill_un,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'duel') AS last_duel,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'ffa') AS last_ffa,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'large') AS last_team,
      arg_max(start_time, start_time) FILTER (WHERE game_type = 'small') AS last_small_team,
      arg_max(new_skill, start_time) FILTER (WHERE game_type = 'small') AS small_team_skill,
      arg_max(new_uncertainty, start_time) FILTER (WHERE game_type = 'small') AS small_team_skill_un
    FROM joined
    WHERE game_type IS NOT null
    GROUP BY user_id
  )
SELECT
  a.user_id AS id,
  p.name,
  a.duel_skill,
  a.duel_skill_un,
  a.ffa_skill,
  a.ffa_skill_un,
  a.team_skill,
  a.team_skill_un,
  a.last_duel,
  a.last_ffa,
  a.last_team,
  p.country_code,
  a.last_small_team,
  a.small_team_skill,
  a.small_team_skill_un
FROM aggregated AS a
INNER JOIN players AS p ON a.user_id = p.user_id
ORDER BY a.user_id
