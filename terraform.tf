terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 0.1.0, < 3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 5.0.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
