# helm-gke-deployments
A repository containing scripts that deploy open source data tools (Airflow, Airbyte, Grafana) to Google Kubernetes Engine (GKE).

There are currently two blogs which outline the usage of scripts in this repo. 
- [Deploying Airflow on GKE using Helm](https://medium.com/@rodelvanrooijen/airflow-on-gke-using-helm-15ca05c11364)
- [Deploying Airbyte on GKE using Helm](https://medium.com/@rodelvanrooijen/deploying-airbyte-on-gke-using-helm-bb15d19c2d1e)

However, in this README there also is step-by-step guide on setting up the deployments.

## Requirements
The following is required to get started:
- The ability to run `bash` commands and scripts (using MacOS, Linux or [WSL2 on Windows](https://learn.microsoft.com/en-us/windows/wsl/install))
- `make` installed to use Makefile commands. 
  - By using [choco](https://chocolatey.org/install) (`choco install make`) on Windows 
  - [Homebrew](https://docs.brew.sh/Installation) on MacOS (`brew install make`)
- An existing Google Cloud Platform (GCP) project.
- (Airflow only) Docker installed (e.g. Docker desktop)
- Multiple IAM roles in your GCP project:
  - GKE Admin permissions (`roles/container.admin`)
  - The ability to create service accounts (`roles/iam.serviceAccountAdmin`)
  - The ability to create a Postgres Cloud SQL instance (`roles/cloudsql.admin`)
  - Manage Google Cloud Storage (GCS) buckets (`roles/storage.admin`) 
  - (Airflow only) Create repos and store images in GCP artifact registry (`roles/artifactregistry.admin`)

### Makefile variables
At the top of the Makefile there are variables defined that you can change if necessary. 
Some of them are required to change for the whole deploy process to work. 
You will need to change: `project_id`, `log_bucket` and the password variables.

### Makefile commands
This repo contains a Makefile with the commands that set-up the various pieces. The following make commands are pre-build for usage:

| Command                                | Description                                                    | Parameters                                                         |
|----------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------------|
| `make init`                            | Initializes authentication with GCP.                           |                                                                    |
| `create-gke-cluster`                   | Creates a GKE cluster.                                         | Requires: `address_name`.                                          |
| `reserve-static-ip`                    | Reserves a static internal IP address in your VPC.             | Requires: `address_name`.                                          |
| `create-airflow-service-account`       | Creates the Airflow service account.                           |                                                                    |
| `create-airflow-db`                    | Creates the Cloud SQL Postgres instance for Airflow.           |                                                                    |
| `create-airflow-image-repo`            | Creates an empty Google Artifact Repository for Docker images. |                                                                    |
| `create-and-push-airflow-custom-image` | Creates a custom Airflow image and pushes it to Repo.          | Requires: `image_version`.                                         |
| `deploy-airflow`                       | Deploys Airflow using Helm to GKE cluster.                     | Requires: `load_balancer_ip`, `postgres_db_ip` and `image_version` |
| `deploy-airflow-dags`                  | Deploys DAGs to Airflow, by copying to persistent volume.      |                                                                    |
| `upgrade-airflow`                      | Upgrades Airflow using custom image.                           | Requires: `load_balancer_ip`, `postgres_db_ip` and `image_version` |
| `create-airbyte-service-account`       | Creates the Airbyte service account.                           |                                                                    |
| `create-airbyte-db`                    | Creates the Cloud SQL Postgres instance for Airbyte.           |                                                                    |
| `deploy-airbyte`                       | Deploys Airbyte using Helm to GKE cluster.                     | Requires: `load_balancer_ip`, `postgres_db_ip`                     |
| `upgrade-airbyte`                      | Upgrades Airbyte using Helm.                                   | Requires: `load_balancer_ip`, `postgres_db_ip`                     |

## GCP
### Cluster creation
To create a GKE cluster you can run `make create-gke-cluster`, note that the `cluster_name` in the Makefile will be used as name for the cluster.

### Reserve static IPs
To reserve a static IP for the load balancers you can use `make address_name=your_address_name reserve-static-ip`. 
Make sure to replace your_address_name with the applicable name.

### Log bucket creation
To create a bucket that can contain logs you can run `make create-log-bucket`.

## Airflow deployment
To deploy Airflow you'll need to:
- Create a service account
- Reserve load balancer IP (see previous, this will be `your_load_balancer_ip`)
- Create a Postgres DB for the meta data
- Create a docker image repo
- Create a custom Airflow image and push to repo
- Deploy Airflow

### Service account
To create the service account for Airflow you can use `make create-airflow-service-account`. 
This will create a service account called `airflow-kubernetes` (based on the default value in the Makefile).

### Database
To create the metadata DB you can use `make create-airflow-db`. 
Remember to save the internal IP address, this will be `your_database_ip`.

Make sure you also adjust the password found in `./airflow-helm/secrets/secret-postgres-credentials.yaml` with your chosen password.

### Docker image repo
To create an empty Airflow custom docker image repo run `make  create-airflow-image-repo`.

### Custom image
To create a custom Airflow image and push it to the created repo run `make image_version=0.1 create-and-push-airflow-custom-image`.
Make sure you remember the `image_version`.

### Deploying
To then deploy Airflow you can use `make load_balancer_ip=your_load_balancer_ip postgres_db_ip=your_database_ip image_version=0.1 deploy-airflow`

## Airbyte deployment
To deploy Airbyte you'll need to:
- Create a service account and generate JSON
- Reserve load balancer IP (see previous, this will be `your_load_balancer_ip`)
- Create a Postgres DB for the meta data
- Deploy Airbyte

### Service account
To create the service account for Airbyte you can use `make create-airbyte-service-account`. 
This will create a service account called `airbyte-kubernetes` (based on the default value in the Makefile).

To now generate the JSON you can use `make generate-service-account-json`. 
The JSON can found in your home directory `cd ~/`, make sure you replace the `service_account.json` in `./airbyte-helm/secrets` with yours.

### Database
To create the metadata DB you can use `make create-airbyte-db`. 
Remember to save the internal IP address, this will be `your_database_ip`.

Make sure you also adjust the password found in `./airbyte-helm/secrets/secret-postgres-credentials.yaml` with your chosen password.

### Deploying
To then deploy Airflow you can use `make load_balancer_ip=your_load_balancer_ip postgres_db_ip=your_database_ip deploy-airbyte`
