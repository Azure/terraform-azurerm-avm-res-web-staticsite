terraform {
  required_version = ">= 1.6.1"
  required_providers {
    # azapi = {
    #   source  = "Azure/azapi"
    #   version = ">= 1.9.0, < 1.14.0"
    # }
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

# data "azurerm_client_config" "this" {}

# data "azurerm_role_definition" "example" {
#   name = "Contributor"
# }

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
  name                = local.azurerm_private_dns_zone_resource_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${azurerm_virtual_network.example.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
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
  # version = "0.4.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.static_web_app.name_unique}-interfaces"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_size            = "Standard"
  sku_tier            = "Standard"

  managed_identities = {
    # Identities can only be used with the Standard SKU

    /*
    system = {
      identity_type = "SystemAssigned"
      identity_ids = [ azurerm_user_assigned_identity.system.id ]
    }
    */

    user = {
      identity_type = "UserAssigned"
      identity_ids  = [azurerm_user_assigned_identity.user.id]
    }

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

  }

  # lock = {

  #   /*
  #   kind = "ReadOnly"
  #   */

  #   /*
  #   kind = "CanNotDelete"
  #   */
  # }

  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = azurerm_subnet.example.id

      # lock = {

      #   /*
      #   kind = "ReadOnly"
      #   */

      #   /*
      #   kind = "CanNotDelete"
      #   */
      # }

      # role_assignments = {
      #   role_assignment_1 = {
      #     role_definition_id_or_name = data.azurerm_role_definition.example.id
      #     principal_id               = data.azurerm_client_config.this.object_id
      #   }
      # }

      tags = {
        webapp = "${module.naming.static_web_app.name_unique}-interfaces"
      }

    }

  }

  # role_assignments = {
  #   role_assignment_1 = {
  #     role_definition_id_or_name = data.azurerm_role_definition.example.id
  #     principal_id               = data.azurerm_client_config.this.object_id
  #   }
  # }

  tags = {
    environment = "dev-tf"
  }
}

# check "dns" {
#   data "azurerm_private_dns_a_record" "assertion" {
#     name                = local.split_subdomain[0]
#     zone_name           = azurerm_private_dns_zone.example.name
#     resource_group_name = azurerm_resource_group.example.name
#   }
#   assert {
#     condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.staticsite.resource_private_endpoints["primary"].private_service_connection).private_ip_address
#     error_message = "The private DNS A record for the private endpoint is not correct."
#   }
# }


# /*

# VM to test private endpoint connectivity

module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.4.0"
}

resource "random_integer" "zone_index" {
  max = length(module.regions.regions_by_name[local.azure_regions[random_integer.region_index.result]].zones)
  min = 1
}

resource "azurerm_network_security_group" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowAllRDPInbound"
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.example.name
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

# Create the virtual machine
module "avm_res_compute_virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.1"

  enable_telemetry = var.enable_telemetry

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.virtual_machine.name_unique}-tf"
  sku_size            = module.avm_res_compute_virtualmachine_sku_selector.sku
  os_type             = "Windows"

  zone = random_integer.zone_index.result

  generate_admin_password_or_ssh_key = false
  admin_username                     = "TestAdmin"
  admin_password                     = "P@ssw0rd1234!"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "nic-${module.naming.network_interface.name_unique}-tf"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1-public"
          private_ip_subnet_resource_id = azurerm_subnet.example.id
          create_public_ip_address      = true
          public_ip_address_name        = "pip-${module.naming.virtual_machine.name_unique}-tf"
          is_primary_ipconfiguration    = true
        }
      }
    }
  }

  tags = {

  }

}

module "avm_res_compute_virtualmachine_sku_selector" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm//modules/sku_selector"
  version = "0.15.1"

  deployment_region = azurerm_resource_group.example.location
}