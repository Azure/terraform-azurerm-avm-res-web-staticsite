terraform {
  required_version = ">= 1.5.2"
  required_providers {
    # TODO: Ensure all required providers are listed here.
    azapi = {
      source  = "azure/azapi"
      version = ">= 0.1.0, < 1.14.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 4.0.0"
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
