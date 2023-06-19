# Deploying Azure Kubernetes Service (AKS) with Terraform

This guide will help you to create an Azure Resource Group and Azure Kubernetes Service (AKS) using Terraform.

## Prerequisites

- You should have [Terraform](https://www.terraform.io/downloads.html) installed.
- You should have [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- You should have [Helm](https://helm.sh/docs/intro/install/) installed. 
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

If you want to use the prepared chart of repo:

`helm upgrade --install -f airflow/values.yaml airflow ./airflow  --namespace airflow --create-namespace --debug`

this will deploy airflow with some predefined DAGs ready for triggering

Configure Airflow on Kubernetes (Optional)
-------------------------------

Export the default values for the Apache Airflow Helm chart to a YAML file (or tweak the modified values.yaml which is present in repo):

`helm show values apache-airflow/airflow > values.yaml`



Accessing Airflow Webserver
---------------------------

To access the Airflow UI, open a new terminal and execute the following command

`kubectl port-forward svc/airflow-webserver 8080:8080 -n airflow`

Then open [http://localhost:8080/](http://localhost:8080/) in your browser:


# ArgoCD Installation & Integration

1\. Deploy ArgoCD on the Kubernetes Cluster
-------------------------------------------

Before starting, create a dedicated namespace for Argo CD to deploy all of its components.

`kubectl create namespace argocd`

Install Argo CD in the `argocd` namespace you created. Use the Argo CD's GitHub repository for the latest Argo CD operator. Deploy it using the following command:


`kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`


2\. Access The Argo CD API Server
---------------------------------

By default, the Argo CD API server is not exposed with an external IP. To access the API server, change the `argocd-server` service type to `LoadBalancer`:

`kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`

Check the service:

`kubectl get svc -n argocd`

Then access the UI from browser:

`http://<argocd-server externalip>:port`

3\. Login Using The CLI
-----------------------

The initial password for the `admin` account is auto-generated and stored as clear text in the field `password` in a secret named `argocd-initial-admin-secret` in your Argo CD installation namespace. You can retrieve this password using `kubectl`:


`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`

You should delete the `argocd-initial-admin-secret` from the Argo CD namespace once you changed the password. The secret serves no other purpose than to store the initially generated password in clear and can safely be deleted at any time.


4\. Deploy the Airflow Application to ArgoCD
-----------------------

Create a project through the UI of ArgoCD and then deploy the app which will sync the changes on the repo chart to AKS cluster.

`kubectl apply -f argoapp.yaml`
