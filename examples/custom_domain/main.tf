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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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
  # version = "0.3.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.static_web_app.name_unique}-custom-domain"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  custom_domains = {
    /*
    # Creating a custom domain with CNAME record currently requires multiple `terraform apply` regardless of depends_on blocks. 
    # To avoid, create the CNAME record manually FIRST in terraform/azure after Static Web App is created, and then create custom domain.
    custom_domain_1 = {
      resource_group_name  = "<resource_group_name_of_dns_zone>"
      domain_name          = "<custom_domain_name>"
    }
    */
  }

  app_settings = {
    # Example
  }

}
