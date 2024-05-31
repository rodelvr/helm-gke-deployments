CLUSTER="gke-cluster"
NAMESPACE="airflow"
ZONE="europe-west1-b"

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT_ID

kubectl delete namespace $NAMESPACE
