gcloud config set project $PROJECT_ID

gcloud compute addresses create $ADDRESS_NAME \
    --region europe-west1 --subnet default

gcloud compute addresses describe $ADDRESS_NAME