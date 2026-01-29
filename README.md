# Data processing

Repository for [ETL](https://en.wikipedia.org/wiki/Extract%2C_transform%2C_load)
workflow that processes BAR data.

It periodically produces public dumps of the matches data combining information
from teiserver and replays database. Check out [Gallery](#gallery) section to
see how community uses this data.

## Data access

Data dumps are available as [Parquet](https://parquet.apache.org/docs/overview/)
under:

- https://data-marts.beyondallreason.dev/matches.parquet
- https://data-marts.beyondallreason.dev/match_players.parquet
- https://data-marts.beyondallreason.dev/players.parquet
- https://data-marts.beyondallreason.dev/player_skill_snapshot.parquet

and Compressed CSV file under:

- https://data-marts.beyondallreason.dev/matches.csv.gz
- https://data-marts.beyondallreason.dev/match_players.csv.gz
- https://data-marts.beyondallreason.dev/players.csv.gz
- https://data-marts.beyondallreason.dev/player_skill_snapshot.csv

More documentation is available at
https://beyond-all-reason.github.io/data-processing/.

### Usage examples

It's easy to load data into Jupyter Notebook or Google Colab, for example:
[plot the number of matches over time](https://colab.research.google.com/drive/1WCDW5v_19ZIk-B-FU-XagdUKssdfIeU_?usp=sharing)
using [Polars](https://pola.rs/).

Given that datasets are available under URL, you can even use [one of the Web
UIs](https://github.com/davidgasquez/awesome-duckdb?tab=readme-ov-file#web-clients)
built on [DuckDB-Wasm](https://github.com/duckdb/duckdb-wasm) to run query
entirely in the browser, for example: [compute number of games per type per month](https://sekuel.com/playground/?q=V0lUSAogIGJhc2UgQVMgKAogICAgU0VMRUNUCiAgICAgIGdhbWVfdHlwZSwKICAgICAgc3RyZnRpbWUoc3RhcnRfdGltZSwgJyVZLSVtJykgQVMgbW9uLAogICAgICBjb3VudCgqKSBBUyBudW0KICAgIEZST00gJ2h0dHBzOi8vZGF0YS1tYXJ0cy5iZXlvbmRhbGxyZWFzb24uZGV2L21hdGNoZXMucGFycXVldCcKICAgIFdIRVJFIHN0YXJ0X3RpbWUgPj0gJzIwMjMtMTAtMDEnCiAgICAgIEFORCBzdGFydF90aW1lIDwgJzIwMjQtMDktMDEnCiAgICBHUk9VUCBCWSAxLCAyCiAgICBPUkRFUiBCWSAxLCAyCiAgKQpQSVZPVCBiYXNlCk9OIG1vbgpVU0lORyBzdW0obnVtKQpPUkRFUiBCWSBnYW1lX3R5cGU7Cg%3D%3D)

## Gallery

Below we want to link some cool examples of how people in the community are
using the data dumps. If you've created something please share with us on
Discord or here in issues!

- [@Atlasfailed](https://github.com/Atlasfailed) shared reports from his
  [personal_skill_analysis](https://github.com/Atlasfailed/personal_skill_analysis)
  project:
  - [personal stats](https://atlasfailed.github.io/personal_skill_analysis/player_134300_analysis.html)
  - [players skill progression](https://atlasfailed.github.io/personal_skill_analysis/player_analysis_report.html)
  - [players retention](https://atlasfailed.github.io/personal_skill_analysis/player_analysis_report.html)
- [@Dazazzell](https://github.com/Dazazzell/barmaps) created a live dashboard
  https://dazazzell.github.io/barmaps/ ([source](https://github.com/Dazazzell/barmaps))
  that shows map popularity stats for the last 60 days.

## Development

This project is using [dbt](https://docs.getdbt.com/docs/introduction) for
managing the SQL pipeline that transforms data and [DuckDB](https://duckdb.org/)
as the query engine.

### Initial

Setup:

```
python3 -m venv .venv
source .venv/bin/activate  # but I also recommend https://direnv.net/ that will load .envrc automatically
pip install -r requirements.txt
```

It's also recommented to install pre commit hooks that will check style of SQL
code before making a commit

```
pre-commit install
```

Note: the project is setup using [uv](https://docs.astral.sh/uv) so you can use it too and need to use it if you plan to modify dependencies.

### Usage

`data_source/dev` contains a small sample of the full data sources used to
genrate full dumps in prod, basic development and testing should be possible
purely on this sample.

To build the data marts from this sample data:

```
dbt run
```

To run tests on the generated data (e.g. validate that fields are not null, or
custom queries return expected results):

```
dbt test
```
