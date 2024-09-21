SELECT
  id AS user_id,
  name
FROM {{ source('pgdumps', 'teiserver_users') }}
