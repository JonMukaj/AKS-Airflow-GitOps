provider "azurerm" {
  features {}
}

provider "helm" {
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate20824"
    container_name       = "tfstate-airflow"
    key                  = "terraform.tfstate"
  }
}

