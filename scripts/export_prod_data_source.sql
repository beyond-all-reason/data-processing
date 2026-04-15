-- noqa: disable=all

ATTACH 'dbname=teiserver_prod' AS teiserver (TYPE POSTGRES, READ_ONLY);

COPY teiserver.public.teiserver_battle_matches TO 'data_export/teiserver_battle_matches.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY teiserver.public.teiserver_battle_match_memberships TO 'data_export/teiserver_battle_match_memberships.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY teiserver.public.teiserver_game_rating_logs TO 'data_export/teiserver_game_rating_logs.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY (SELECT * EXCLUDE (password) FROM teiserver.public.account_users) TO 'data_export/teiserver_users.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY teiserver.public.teiserver_account_user_stats TO 'data_export/teiserver_user_stats.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);

COPY (
  SELECT e.id, e.timestamp, e.value, false AS is_anon
  FROM teiserver.public.analytics_complex_client_events AS e
  INNER JOIN teiserver.public.analytics_complex_client_event_types AS t
    ON e.event_type_id = t.id
  WHERE t.name = 'system:benchmark'
) TO 'data_export/teiserver_benchmark_events.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);

COPY (
  SELECT e.id, e.timestamp, e.value, true AS is_anon
  FROM teiserver.public.analytics_complex_anon_events AS e
  INNER JOIN teiserver.public.analytics_complex_anon_event_types AS t
    ON e.event_type_id = t.id
  WHERE t.name = 'system:benchmark'
) TO 'data_export/teiserver_benchmark_anon_events.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);

ATTACH 'dbname=bar' AS replay (TYPE POSTGRES, READ_ONLY);

COPY replay.public.Demos TO 'data_export/replay_demos.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY replay.public.AllyTeams TO 'data_export/replay_ally_teams.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY replay.public.Players TO 'data_export/replay_players.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
COPY replay.public.Maps TO 'data_export/replay_maps.parquet' (FORMAT 'parquet', CODEC 'zstd', COMPRESSION_LEVEL 9);
