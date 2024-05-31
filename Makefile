# GCP Variables
project_id = "<YOUR_PROJECT_ID>"  # Make sure to replace this
region = "europe-west1"
zone = "europe-west1-b"

# GKE Cluster Variables
cluster_name = "gke-cluster"
machine_type = "n2-standard-4" # Adjust this if wanted
min_number_of_nodes = 1
max_number_of_nodes = 3

# Airflow Variables
postgres_airflow_db_name = "postgres-airflow-db"
postgres_airflow_db_password = "<KEEP THIS SAFE!>" # Make sure to replace this
airflow_service_account_name = "airflow-kubernetes"
airflow_repo_name = "airflow-custom-images"
airflow_log_bucket = "<YOUR LOG BUCKET>" # Make sure to replace this
airflow_dags_path = "airflow" # Relative path to parent folder of dags
airflow_helm_version = "8.8.0"
scheduler_replicas = 2
worker_replicas = 2

# Airbyte Variables
postgres_airbyte_db_name = "postgres-airbyte-db"
postgres_airbyte_db_password = "<KEEP THIS SAFE!>" # Make sure to replace this
airbyte_service_account_name = "airbyte-kubernetes"
airbyte_log_bucket = "<YOUR LOG BUCKET>" # Make sure to replace this
airbyte_helm_version = "0.94.1"

# Hardware variable (https://docs.docker.com/build/building/multi-platform/)
hardware_platform = "linux/amd64" # Make sure to change this is if deploying to non-x86-64

# Makefile command prefixes
continue_on_error = -
suppress_output = @

.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

help: ## This is help
	$(suppress_output)awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## authenticate
	$(suppress_output)echo "Authenticating and creating authentication files...."
	gcloud auth application-default login


# ---- GENERIC GCP/GKE ----

# Create GKE cluster on GCP
create-gke-cluster:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	MACHINE_TYPE=machine_type \
	MIN_NUMBER_OF_NODES=min_number_of_nodes \
	MAX_NUMBER_OF_NODES=max_number_of_nodes \
	bash ./gke-cluster/create-cluster.sh

# Reserves static internal IP within VPC
# Example: make address_name=airflow-api-ip reserve-static-ip
reserve-static-ip:
	PROJECT_ID=project_id \
	ADDRESS_NAME=$(address_name) \
	bash ./gke-cluster/reserve-static-ip.sh


# ---- AIRFLOW ----

# Create airflow service account
create-airflow-service-account:
	PROJECT_ID=project_id \
	AIRFLOW_SERVICE_ACCOUNT_NAME=airflow_service_account_name \
	bash ./airflow-helm/scripts/create-service-account.sh

# Create (external) postgres DB
create-airflow-db:
	DB_NAME=postgres_airflow_db_name \
	POSTGRES_VERSION=POSTGRES_16 \
	DB_ROOT_PASSWORD=postgres_airflow_db_password \
	bash ./gke-cluster/create-postgres-db.sh

# Create artifact repository for custom images
create-airflow-image-repo:
	PROJECT_ID=project_id \
	REGION=region \
	AIRFLOW_REPO_NAME=airflow_repo_name \
	bash ./airflow-helm/scripts/create-repo.sh

# Create Airflow custom image
# Example make image_version=0.1 create-and-push-airflow-custom-image
create-and-push-airflow-custom-image:
	PROJECT_ID=project_id \
	REGION=region \
	AIRFLOW_REPO_NAME=airflow_repo_name \
	IMAGE_NAME=airflow-custom \
	VERSION=$(image_version) \
	HARDWARE_PLATFORM=hardware_platform \
	bash ./airflow-helm/scripts/build-and-push-image.sh

# Deploy Airflow
# Example make load_balancer_ip=10.0.0.1 postgres_db_ip=10.0.0.1 image_version=0.1 deploy-airflow
deploy-airflow:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	REGION=region \
	AIRFLOW_HELM_VERSION=airflow_helm_version \
	SERVICE_ACCOUNT_NAME=airflow_service_account_name \
	LOAD_BALANCER_IP=$(load_balancer_ip) \
	SCHEDULER_REPLICAS=scheduler_replicas \
	WORKER_REPLICAS=worker_replicas \
	DATABASE_HOST_IP=$(postgres_db_ip) \
	LOG_BUCKET=airflow_log_bucket \
	AIRFLOW_REPO_NAME=airflow_repo_name \
	CUSTOM_IMAGE_VERSION=$(image_version) \
	bash ./airflow-helm/scripts/deploy-airflow.sh

# Deploy DAGs to Airflow's persistent volume
deploy-airflow-dags:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	CLUSTER_ZONE=zone \
	AIRFLOW_DAGS_PATH=airflow_dags_path \
	bash ./airflow-helm/scripts/deploy-airflow-dags.sh


# Upgrade Airflow Helm/Image
# Example: make load_balancer_ip=10.0.0.1 postgres_db_ip=10.0.0.2 image_version=0.2 upgrade-airflow
upgrade-airflow:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	AIRFLOW_HELM_VERSION=airflow_helm_version \
	LOAD_BALANCER_IP=$(load_balancer_ip) \
	SCHEDULER_REPLICAS=scheduler_replicas \
	WORKER_REPLICAS=worker_replicas \
	DATABASE_HOST_IP=$(postgres_db_ip) \
	LOG_BUCKET=airflow_log_bucket \
	AIRFLOW_REPO_NAME=airflow_repo_name \
	CUSTOM_IMAGE_VERSION=$(image_version) \
	bash ./airflow-helm/scripts/upgrade-airflow.sh

# Make Airflow webservice available locally
port-forward-airflow:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	LOCAL_PORT=8080 \
	bash ./airflow-helm/scripts/port-forward.sh

# ---- AIRBYTE ----

# Create (external) postgres DB for Airbyte
create-airbyte-db:
	DB_NAME=postgres_airbyte_db_name \
	POSTGRES_VERSION=POSTGRES_13 \
	DB_ROOT_PASSWORD=postgres_airbyte_db_password \
	bash ./gke-cluster/create-postgres-db.sh

# Deploys Airbyte to the GKE cluster
# Example: make load_balancer_ip=10.0.0.1 postgres_db_ip=10.0.0.2 deploy-airbyte
deploy-airbyte:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	AIRBYTE_HELM_VERSION=airbyte_helm_version \
	SERVICE_ACCOUNT_NAME=airbyte_service_account_name \
	BUCKET=airbyte_log_bucket \
	LOAD_BALANCER_IP=$(load_balancer_ip) \
  	DATABASE_HOST=$(postgres_db_ip) \
  	bash ./airbyte-helm/scripts/deploy-airbyte.sh

# Upgrades Airbyte to the selected helm version
# Example: make load_balancer_ip=10.0.0.1 postgres_db_ip=10.0.0.2 upgrade-airbyte
upgrade-airbyte:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	AIRBYTE_HELM_VERSION=airbyte_helm_version \
	SERVICE_ACCOUNT_NAME=airbyte_service_account_name \
	BUCKET=airbyte_log_bucket \
	LOAD_BALANCER_IP=$(load_balancer_ip) \
  	DATABASE_HOST=$(postgres_db_ip) \
  	bash ./airbyte-helm/scripts/deploy-airbyte.sh

 # Make Airbyte webservice available locally
port-forward-airbyte:
	PROJECT_ID=project_id \
	CLUSTER_NAME=cluster_name \
	ZONE=zone \
	LOCAL_PORT=8081 \
	bash ./airbyte-helm/scripts/port-forward.sh