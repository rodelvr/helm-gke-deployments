gcloud artifacts repositories create $AIRFLOW_REPO_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="Airflow docker image repository" \
    --project=$PROJECT_ID