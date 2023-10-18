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
- `terraform/main.tf` & `terraform/variables.tf` - These assets are the starter point to deploy our infrastructure to the cloud. This will be covered in Lab 1.


## Labs

### Lab 1: Setup Composer using Terraform
During the slides in the opening section of the day, you have created an instance of Cloud Composer using the UI in the Google Cloud Console. In this lab, we will create a Cloud Composer using best practices of Infrastructure-as-Code (IaC). The standard tool for this task is [Terraform](https://www.terraform.io/).

In the `terraform` subfolder of this repo, there is some boilerplate code to get you started. In that repo you will find a `main.tf` entry point, and a `variables.tf` to define input variables. In a real-world terraform project, you would find more complex structures, to include sub-modules, each carrying their own resources, variables, dependenceis etc. For the sake of this lab, and considering this workshop is about Cloud Composer, and not Terraform, we will use "KISS" (Keep it Simple, señor).

Your task, if you choose to accept it - change your working directory to the `terraform` subdirectory, make the appropriate changes to source files there, and try to use it to deploy your second Cloud Composer instance.

### Lab 2: Setup CI/CD pipeline on deployed DAG

### Lab 3: Modify the test DAG to use secret manager and BQ

### Lab 4: [Time Permitting] Adapt the CI/CD pipeline to deploy changes to a Custom Operator