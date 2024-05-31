NAMESPACE="airbyte"
LOAD_BALANCER_PORT=8000

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

kubectl port-forward svc/airbyte-airbyte-webapp-svc $LOCAL_PORT:$LOAD_BALANCER_PORT --namespace $NAMESPACE 2>&1 >/dev/null &
