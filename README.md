# Data processing

Repository for [ETL](https://en.wikipedia.org/wiki/Extract%2C_transform%2C_load)
workflow that processes BAR data from different sources and creates data dumps.

At the moment the only functionality is a public dump of the past matches data
combining information from teiserver and replays databases.

## Data access

Documentation about accessing dumps generated with pipeling in this repository
is available at https://beyond-all-reason.github.io/data-processing/.

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
