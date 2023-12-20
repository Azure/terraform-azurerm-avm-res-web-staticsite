terraform {
  required_version = ">= 1.5.2"
  required_providers {
    # TODO: Ensure all required providers are listed here.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 0.1.0"
    }
  }
}
