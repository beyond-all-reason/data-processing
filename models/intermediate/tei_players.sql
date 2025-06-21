SELECT
  tu.id AS user_id,
  tu.name,
  CASE
    WHEN tus.data ->> 'country' = '??' THEN NULL
    ELSE tus.data ->> 'country'
  END AS country
FROM {{ source('pgdumps', 'teiserver_users') }} AS tu
LEFT JOIN {{ source('pgdumps', 'teiserver_user_stats') }} AS tus
  ON tu.id = tus.user_id
