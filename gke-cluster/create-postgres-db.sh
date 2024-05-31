gcloud sql instances create $DB_NAME \
      --database-version=$POSTGRES_VERSION \
      --cpu=1 \
      --memory=4GB \
      --region=europe-west1 \
      --no-assign-ip \
      --enable-google-private-path \
      --root-password=$DB_ROOT_PASSWORD