# Composer-Day

## What is this?
This repository contains some, snippets, boilerplates and setup scripts to help you get started with the Composer Day Workshop.

The Composer day workshop will help you get started with Google Cloud Composer, Googles managed [Apache Airflow](https://airflow.apache.org/) orchastrator for managing your data pipelines in the cloud. 

## How to use?
Best way is to fork this repository to your own GitHub account. we will use the repo to create a CI/CD workflow, to test and deploy your DAGs.

Another option is to download the repo as a zip file, and setup your own git repo - the ideas should be transferaable to other source control platforms other then GitHub.

## Scripts and assets

- `setup-scripts/setup-bq-data.sh` - this bash script will download some sample files to your local working directory, create corrosponding BigQuery tables, and load the data to them. The data is taken from Googles Air quality project made in Hamburg, where air quality readings were taken throughout the city. There is a `greenhat.readings` table, which contains the actual readings, including long-lat coordinates, the `greenhat.road_config` table, that contains information about the different roads and streets where the readings were taken, and a `greenhat.space_and_time_continuum` table that is used as a join table. The datasets here are stictly used as an example, and there won't be a need to dive deep into the actual data.
- `dags/first-dag.py` - This will be our first dag that we will deploy. It will use a [Bash Operator](https://airflow.apache.org/docs/apache-airflow/stable/_api/airflow/operators/bash/index.html#module-airflow.operators.bash) to verify a target BigQuery Dataset exists (or it will create it), use a [BigQuery Operator](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/operators/cloud/bigquery.html) to create a sample aggregate table using a `BigQueryInsertJobOperator` operator using also some runtime arguments, then two export jobs will start in parallel to export the aggregated data into a target bucket (already should have been created by the setup script), once in CSV format, and once in AVRO format. The last step is just a placeholder, to say goodbye, in Python.