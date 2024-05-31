gcloud iam service-accounts create $AIRFLOW_SERVICE_ACCOUNT_NAME \
  --description="User-managed service account for the Airflow deployment" \
  --display-name="Airflow Kubernetes"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$AIRFLOW_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/container.admin \
  --role=roles/iam.serviceAccountUser \
  --role=roles/iam.workloadIdentityUser \
  --role=roles/storage.admin