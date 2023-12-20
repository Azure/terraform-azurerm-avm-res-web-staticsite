terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# Helps pick a random region from the list of regions.
resource "random_integer" "region_index" {
  min = 0
  max = length(local.azure_regions) - 1
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name_unique
  location = local.azure_regions[random_integer.region_index.result]
}

# This is the module call
module "staticsite" {
  source = "../../"
  # source             = "Azure/avm-res-web-staticsite/azurerm"
  # ...

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.static_web_app.name_unique}-free"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  repository_url = ""
  branch         = ""

  identities = {
    # Identities can only be used with the Standard SKU
  }

  app_settings = {
    # Example
  }

}
