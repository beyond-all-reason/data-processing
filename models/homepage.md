{% docs __overview__ %}

# BAR Data Processing

This is a automatically generated documentation for BAR data processing project. The project is built using
[dbt](https://docs.getdbt.com/docs/introduction).

## Data access

All exported data is accesible for download under 2 formats:

- [Parquet](https://parquet.apache.org/docs/overview/): `.parquet` extention
- Compressed CSV file, `.csv.gz` extension

The URL is `https://data-marts.beyondallreason.dev/{model}{extension}`.
For example, to download [`matches`](#!/model/model.bar_data_processing.matches)
model (data table) in Parquet format, URL is:
https://data-marts.beyondallreason.dev/matches.parquet

## Schamas

To browse schema of all exported models (data tables) navigate on the left side
to: `bar_data_processing > models > marts`.

![navigation](assets/navigation.png)

The `intermediate` models are not exported as those are just intermediate steps
in generation of the final `marts`.

## Browsing documentation

This documentation contains information about all sources and processing steps
in the data transformation pipeline that generates the exported models. One
of the example useful features is the
[lineage graph](https://docs.getdbt.com/terms/data-lineage) you can access by
clicking the blue icon on the bottom-right corner of the page.

{% enddocs %}
