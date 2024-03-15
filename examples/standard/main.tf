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
  max = length(local.azure_regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "staticsite" {
  source = "../../"

  # source             = "Azure/avm-res-web-staticsite/azurerm"
  # version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.static_web_app.name_unique}-standard"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_tier            = "Standard"
  sku_size            = "Standard"

  repository_url = ""
  branch         = ""

  identities = {
    # Identities can only be used with the Standard SKU

    /*
    system = {
      identity_type = "SystemAssigned"
      identity_resource_ids  = []
    }
    */

    /*
    user = {
      identity_type = "UserAssigned"
      identity_resource_ids = []
    }
    */

    /*
    system_user = {
      identity_type = "SystemAssigned, UserAssigned"
      identity_resource_ids = []
    }
    */
  }

  app_settings = {
    # Example
  }
}
