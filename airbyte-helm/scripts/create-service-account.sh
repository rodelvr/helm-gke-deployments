gcloud iam service-accounts create $AIRBYTE_SERVICE_ACCOUNT_NAME \
  --description="User-managed service account for the Airbyte deployment" \
  --display-name="Airbyte Kubernetes"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$AIRBYTE_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/container.admin \
  --role=roles/iam.serviceAccountUser \
  --role=roles/iam.workloadIdentityUser \
  --role=roles/storage.admin