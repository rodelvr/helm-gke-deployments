NAMESPACE="airflow"
LOAD_BALANCER_PORT=443

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

kubectl port-forward svc/$NAMESPACE-web $LOCAL_PORT:$LOAD_BALANCER_PORT --namespace $NAMESPACE 2>&1 >/dev/null &
