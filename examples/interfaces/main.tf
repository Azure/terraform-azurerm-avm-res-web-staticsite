terraform {
  required_version = ">= 1.5.2"
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

data "azurerm_client_config" "this" {}

data "azurerm_role_definition" "example" {
  name = "Contributor"
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_virtual_network" "example" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.azurestaticapps.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

# This is the module call
module "staticsite" {
  source = "../../"

  # source             = "Azure/avm-res-web-staticsite/azurerm"
  # version = "0.1.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.static_web_app.name_unique}-interfaces"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_size            = "Standard"
  sku_tier            = "Standard"

  repository_url = ""
  branch         = ""

  identities = {
    # Identities can only be used with the Standard SKU

    /*
    system = {
      identity_type = "SystemAssigned"
      identity_ids = [ azurerm_user_assigned_identity.system.id ]
    }
    */

    /*
    user = {
      identity_type = "UserAssigned"
      identity_ids = [ azurerm_user_assigned_identity.user.id ]
    }
    */

    /*
    system_and_user = {
      identity_type = "SystemAssigned, UserAssigned"
      identity_resource_ids = [
        azurerm_user_assigned_identity.user.id
      ]
    }
    */
  }

  app_settings = {
    # Example
  }

  lock = {

    kind = "None"

    /*
    kind = "ReadOnly"
    */

    /*
    kind = "CanNotDelete"
    */
  }

  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = azurerm_subnet.example.id

      inherit_lock = true
      inherit_tags = true

      lock = {
        /*
        # kind = "None"
        */

        /*
        kind = "ReadOnly"
        */

        /*
        kind = "CanNotDelete"
        */
      }

      role_assignments = {
        role_assignment_1 = {
          role_definition_id_or_name = data.azurerm_role_definition.example.id
          principal_id               = data.azurerm_client_config.this.object_id
        }
      }

      tags = {
        webapp = "${module.naming.static_web_app.name_unique}-interfaces"
      }

    }

  }

  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = data.azurerm_role_definition.example.id
      principal_id               = data.azurerm_client_config.this.object_id
    }
  }

  tags = {
    environment = "dev-tf"
  }
}

check "dns" {
  data "azurerm_private_dns_a_record" "assertion" {
    name                = module.naming.static_web_app.name_unique
    zone_name           = "privatelink.azurestaticapps.net"
    resource_group_name = azurerm_resource_group.example.name
  }
  assert {
    condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.staticsite.private_endpoints["primary"].private_service_connection).private_ip_address
    error_message = "The private DNS A record for the private endpoint is not correct."
  }
}
