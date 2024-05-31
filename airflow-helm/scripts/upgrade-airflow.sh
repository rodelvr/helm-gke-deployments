export DEPLOYMENT_NAME="airflow"
export KUBERNETES_SERVICE_ACCOUNT="airflow"
export AIRFLOW_NAMESPACE="airflow"

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

## install using helm 3
helm upgrade \
  --install \
  "$DEPLOYMENT_NAME" \
  airflow-stable/airflow \
  --namespace "$AIRFLOW_NAMESPACE" \
  --version "$AIRFLOW_HELM_VERSION" \
  --values ./airflow-helm/custom-values.yaml \
  --set web.service.loadBalancerIP=$LOAD_BALANCER_IP \
  --set scheduler.replicas=$SCHEDULER_REPLICAS \
  --set workers.replicas=$WORKER_REPLICAS \
  --set externalDatabase.host=$DATABASE_HOST_IP \
  --set airflow.image.repository=$REGION-docker.pkg.dev/$PROJECT_ID/$AIRFLOW_REPO_NAME/airflow-custom \
  --set airflow.config.AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER=gs://$LOG_BUCKET/airflow/logs \
  --set airflow.image.tag=$CUSTOM_IMAGE_VERSION
