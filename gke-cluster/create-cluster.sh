gcloud config set project $PROJECT_ID

gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --project $PROJECT_ID \
  --machine-type $MACHINE_TYPE \
  --num-nodes $MIN_NUMBER_OF_NODES \
  --scopes "cloud-platform" \
  --autoscaling-profile "optimize-utilization" \
  --enable-autoscaling --min-nodes=$MIN_NUMBER_OF_NODES --max-nodes=$MAX_NUMBER_OF_NODES \
  --workload-pool $PROJECT_ID.svc.id.goog