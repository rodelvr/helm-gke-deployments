export DEPLOYMENT_NAME="airbyte"
export AIRBYTE_NAMESPACE="airbyte"

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

## install using helm 3
helm upgrade \
  --install \
  "$DEPLOYMENT_NAME" \
  airbyte/airbyte \
  --namespace "$AIRBYTE_NAMESPACE" \
  --version "$AIRBYTE_HELM_VERSION" \
  --values ./airbyte-helm/custom-values.yaml \
  --set global.storage.bucket.log=$BUCKET \
  --set global.storage.bucket.state=$BUCKET \
  --set global.storage.bucket.workloadOutput=$BUCKET \
  --set webapp.service.loadBalancerIP=$LOAD_BALANCER_IP \
  --set externalDatabase.host=$DATABASE_HOST
