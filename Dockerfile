FROM postgres:13

RUN apt-get update && apt-get install -y && apt-get install python3-pip -y

RUN apt-get install Python3.8 

ARG AIRFLOW_VERSION=2.2.4 

ARG PYTHON_VERSION=3.8 

ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt" 

RUN pip install "apache-airflow[postgres]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}" 