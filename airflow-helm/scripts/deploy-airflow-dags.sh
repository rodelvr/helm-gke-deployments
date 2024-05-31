CLUSTER_NAMESPACE="airflow"

gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID

kubectl config set-context --current --namespace=$CLUSTER_NAMESPACE

kubectl run airflow-dags-sync \
  --image=busybox \
  --restart=Never \
  --overrides='{"apiVersion": "v1", "spec": {"containers": [{"name": "airflow-dags-sync", "image": "busybox", "command": ["tail"], "args": ["-f", "/dev/null"], "volumeMounts": [{"mountPath": "var/airflow/dags", "name": "airflow-dags-pv"}]}], "volumes": [{"name": "airflow-dags-pv", "persistentVolumeClaim": {"claimName": "airflow-dags-pvc"}}]}}'
while [[ $(kubectl get pod -l run=airflow-dags-sync -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo "Waiting for the pod to be Ready..."
    sleep 2
done

POD_NAME=$(kubectl get pod -l run=airflow-dags-sync -o jsonpath="{.items[0].metadata.name}")

kubectl exec $POD_NAME -- sh -c 'rm -rf /var/airflow/dags/*' && kubectl cp ./"$AIRFLOW_DAGS_PATH">/dags/. $POD_NAME:/var/airflow/dags/

kubectl delete pod airflow-dags-sync