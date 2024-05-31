import pendulum

from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import timedelta

default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "catchup": False,
    "max_active_runs": 2,
}


dag = DAG(
    "airflow_monitoring",
    default_args=default_args,
    description="Monitoring Airflow DAG",
    tags=["Core"],
    start_date=pendulum.today("UTC").add(days=-1),
    schedule="*/10 * * * *",
    dagrun_timeout=timedelta(minutes=10),
)

# priority_weight has type int in Airflow DB, uses the maximum.
airflow_monitor = BashOperator(
    task_id="echo",
    bash_command="echo test",
    dag=dag,
    depends_on_past=False,
    priority_weight=2**31 - 1,
    do_xcom_push=False,
)
