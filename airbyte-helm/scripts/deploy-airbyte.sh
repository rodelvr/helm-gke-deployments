export DEPLOYMENT_NAME="airbyte"
export AIRBYTE_NAMESPACE="airbyte"

gcloud config set project $PROJECT_ID

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

kubectl create ns "$AIRBYTE_NAMESPACE"

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[$AIRBYTE_NAMESPACE/$SERVICE_ACCOUNT_NAME]"

kubectl create secret generic service-account-json \
  --from-file=gcp.json=airbyte-helm/secrets/service_account.json \
  --namespace=$AIRBYTE_NAMESPACE

kubectl apply -k ./airbyte-helm/secrets -n "$AIRBYTE_NAMESPACE"

helm install \
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

kubectl apply -f ./airbyte-helm/metrics-server-pdb.yaml

kubectl apply -f ./airbyte-helm/kube-dns-pdb.yaml

