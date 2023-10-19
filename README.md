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


Useful commands in terraform:
- “terraform init”
- “terraform plan” 
- “terraform apply”
- [Optional] “terraform refresh” [[docs]](https://developer.hashicorp.com/terraform/cli/commands/refresh)


Useful documentation:
- [Create environments with Terraform | Cloud Composer](https://cloud.google.com/composer/docs/composer-2/terraform-create-environments)
- [google_composer_environment | Resources | hashicorp/google | Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/composer_environment)

### Lab 2: Setup CI/CD pipeline on deployed DAG
For this lab, we would want create a CI/CD pipeline, using your own GitHub account, to automate the testing and deployment of DAGs to the Cloud Composer environment.

In the `dags` folder, there is one dag, named `first_dag.py`. As described above, this DAG is performing some boilerplate operations.

As a first step, you could try to deploy the dag manually, using the command:
```bash
gcloud composer environments storage dags import \
    --environment <YOUR_ENVIRONMENT_NAME> \
    --location <LOCATION> \
    --source <RELATIVE_PATH_TO_DAG>
```
**Note 1**: LOCATION should be `us-central1` in this workshop, unless you changed it. You can verify all the required details missingby running:
```bash
gcloud composer environments list --locations us-central1
```

**Note 2**: This command is merly copying the python DAG file to the associated Cloud Storage bucket. That is important do understand while building your CI/CD pipeline.

To start implementing the CI/CD pipeline based on your GitHub repository, you can consult the official published example repository 


#### Goals for this lab:
- Use the provisioned composer instance from lab 2 to setup a CI/CD pipeline with cloud build and your github repository
- Refer to [https://cloud.google.com/composer/docs/dag-cicd-integration-guide](https://cloud.google.com/composer/docs/dag-cicd-integration-guide) to setup your CI/CD architecture
- Link your github repository to cloud build
    - Navigate to cloud build menu and click on create trigger to get started
- Configure 2 triggers
    - Create the Cloud Build trigger for the presubmit check
        - CI -> when a PR is created to main branch tests are built
        - For the unit test use the provided test [[guide]](https://cloud.google.com/composer/docs/dag-cicd-integration-guide#builder-yaml-presubmit)
    - Create the Cloud Build trigger for DAG sync job 
        - CD ->  DAGs folder in GCS updated when changes merged to main branch 
        - The [[dags-utility]](https://cloud.google.com/composer/docs/dag-cicd-integration-guide#dags-utility) python file contains the logics for uploading local DAGs to composer DAGs folder
- Test both triggers are successful 


**Bonus Points** - change the deployment script to create a subfolder structure under the main `dags` folder, so in a real-world use-case each team that creates a flow, can have their flow deployed to their own subfolder (someone said `namespaces` for flows?).


### Lab 3: Modify the test DAG to use secret manager and BQ

In this lab we will connect [Google Cloud Secret Manager](https://cloud.google.com/secret-manager), a secure and convenient storage system for API keys, passwords, certificates, and other sensitive data, to our Cloud Composer instance, so any code running in Cloud Composer can make use of the secrets managed by Secret Manager.

While Apache Airflow offers a built in variable storage for you to use out of the box, it is not really secure, and very difficult to share secrets with other parts of your cloud infrastructure. The benefits of using Secret Manager to hold sensative data for you, and connecting it to Cloud Composer are that DAG developers don't have to access and be exposed to sensative data while developing, keeping the secret values safe and secure, while these secrets are re-usable with other cloud resources. 

Useful resources:
- [Configure Secret Manager for your environment](https://cloud.google.com/composer/docs/composer-2/configure-secret-manager#gcloud)
- [Override Airflow configuration options](https://cloud.google.com/composer/docs/composer-2/override-airflow-configurations)
- [Creating a secret in Secret Manager](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets)

The simplest way to see this in action, is to modify one of your steps to use a variable (that will be read from Secret Manager).

For example, consider changing the last python step from this:
```python
this_is_the_end = python_operator.PythonOperator(
        task_id="goodbye", 
        python_callable=greeting,
    )
```
To this:
```python
this_is_the_end = python_operator.PythonOperator(
        task_id="goodbye", 
        provide_context=True,
        python_callable=greeting,
        op_kwargs={'name': '{{ var.value.name }}'},
    )
```

### Lab 4: [Time Permitting] Adapt the CI/CD pipeline to deploy changes to a Custom Operator

**Congrats for making it this far**

For this challenge we want to take our flow the last step and have it use repeatable custom logic that you can encapsulate in a custom operator. As a Data Platform team, it is your job to make sure other teams in your organization can work in *Congruence* without too much friction. So abstracting away from them as many technical details as possible, allowing them to focus on buisness specific logic. 

Your Goals:
- Manually install the given RGCustomOperator provided to you with the starter code using the gcloud command:
```bash
gcloud composer environments storage plugins import \
    --environment <YOUR_ENVIRONMENT_NAME> \
    --location <LOCATION> \
    --source <RELATIVE_PATH_TO_PLUGIN_FILE>
```
- Adapt your DAG to use the RGCustomOperator
- Adapt your CI/CD pipeline to copy also deploy plugins and not just DAGs
    - Modify utilities script and merge-to-main trigger 
    - Test your CI/CD pipeline by changing the log message in the RGCustomOperator code

**Note** that it can 2-3 minutes for the new operator changes to reflect
