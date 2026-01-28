-- noqa: disable=all

COPY 'data_export/matches.parquet' TO 'data_export/matches.csv.gz';
COPY 'data_export/match_players.parquet' TO 'data_export/match_players.csv.gz';
COPY 'data_export/players.parquet' TO 'data_export/players.csv.gz';
COPY 'data_export/player_skill_snapshot.parquet' TO 'data_export/player_skill_snapshot.csv';
