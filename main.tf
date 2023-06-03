resource "azurerm_resource_group" "airflow-rg" {
  name     = "k8s-airflow"
  location = "East US 2"
}


resource "azurerm_kubernetes_cluster" "k8s_airflow" {
  name                = "k8s-airflow"
  location            = azurerm_resource_group.airflow-rg.location
  resource_group_name = azurerm_resource_group.airflow-rg.name
  dns_prefix          = "k8s-airflow-dns"

  default_node_pool {
    name            = "agentpool"
    node_count      = 2
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 128
    type            = "VirtualMachineScaleSets"
    max_pods        = 110
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "/subscriptions/93926984-76f9-4895-99d7-b4b87fac5e67/resourceGroups/DefaultResourceGroup-EUS2/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-93926984-76f9-4895-99d7-b4b87fac5e67-EUS2"
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"

    load_balancer_profile {
      managed_outbound_ip_count = 1
    }
    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    outbound_type      = "loadBalancer"
  }

  service_principal {
    client_id = "msi"
  }

  tags = {
    Environment = "Production"
  }
}