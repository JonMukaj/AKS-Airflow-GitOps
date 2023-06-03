# Deploying Azure Kubernetes Service (AKS) with Terraform

This guide will help you to create an Azure Resource Group and Azure Kubernetes Service (AKS) using Terraform.

## Prerequisites

- You should have [Terraform](https://www.terraform.io/downloads.html) installed.
- You should have [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- You need to be authenticated to Azure. Use the following guide https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash.

## Setup

1. Initialize your Terraform workspace, which will download the provider and initialize it with the values provided in the `versions.tf` file:

    ```
    terraform init
    ```

2. Create a new plan to check the resources to be created

    ```
    terraform plan
    ```

3. Apply to deploy resources

    ```
    terraform apply
    ```
    
## Connect to the Azure Kubernetes Service (AKS)

After the AKS cluster is deployed, you will need to get the credentials to connect to the cluster. You can do this using the Azure CLI.

1\. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) if you haven't done so already.

2\. Run the following command to get the credentials:

    ```

    az aks get-credentials --resource-group k8s-airflow-rg --name k8s-airflow

    ```

    Replace `k8s-airflow-rg` with the name of your resource group and `k8s-airflow` with the name of your AKS cluster.

This command will download the credentials and configure your local `kubectl` context to connect to the cluster. `kubectl` is the Kubernetes command-line tool, which allows you to run commands against Kubernetes clusters.

3\. You can verify the connection to your cluster by running the following command:

    ```

    kubectl get nodes

    ```

    This will list the nodes in your cluster. If you see your nodes listed, you are correctly connected to your AKS cluster.


# Deploy Airflow on Kubernetes

Add the official Apache Airflow Helm chart to your Helm repository, update the repository, check for the Airflow chart, and deploy it to your cluster:

Add the official Apache Airflow Helm chart to your Helm repository

`helm repo add apache-airflow https://airflow.apache.org`

Update the repository

`helm repo update`

Check for the Airflow chart

`helm search repo airflow`

Deploy chart to k8s cluster

`helm install airflow apache-airflow/airflow --namespace airflow --create-namespace --debug`

--debug flag will provide the default credentials of airflow account and postgres


After some minutes check the status of your pods:


`kubectl get pods -n airflow`


Configure Airflow on Kubernetes
-------------------------------

Export the default values for the Apache Airflow Helm chart to a YAML file (or tweak the modified values.yaml which is present in repo):

`helm show values apache-airflow/airflow > values.yaml`



Accessing Airflow Webserver
---------------------------

To access the Airflow UI, open a new terminal and execute the following command

`kubectl port-forward svc/airflow-webserver 8080:8080 -n airflow`

Then open `http://localhost:8080/` in your browser:
