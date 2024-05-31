docker build . \
  -f airflow_helm/Dockerfile \
  -t $REGION-docker.pkg.dev/$PROJECT_ID/$AIRFLOW_REPO_NAME/$IMAGE_NAME:$VERSION \
  --platform=$HARDWARE_PLATFORM

docker push $REGION-docker.pkg.dev/$PROJECT_ID/$AIRFLOW_REPO_NAME/$IMAGE_NAME:$VERSION