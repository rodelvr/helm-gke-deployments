# Use the official Airflow image as a parent image
FROM apache/airflow:2.8.4-python3.11

USER root

# Copy requirements to working directory
COPY airflow-helm/requirements/requirements.txt /var/airflow/requirements.txt

# Set the working directory in the container
WORKDIR /var/airflow

# Create plugins and dags directory
RUN mkdir -p /var/airflow/plugins

# Create plugins and dags directory
RUN chmod -R 777 /var/airflow/plugins

# Copy plugins and dags to folders (change if necessary)
COPY airflow/plugins/. /var/airflow/plugins/

USER airflow

# Install the necessary dependencies
RUN pip install \
    --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.4/constraints-3.11.txt" \
    "apache-airflow==2.8.4" -r /var/airflow/requirements.txt