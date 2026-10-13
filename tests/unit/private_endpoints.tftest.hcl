mock_provider "azapi" {
  alias = "mocked"
}

mock_provider "azurerm" {
  alias = "mocked"

  mock_resource "azurerm_static_web_app" {
    defaults = {
      id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/site/providers/Microsoft.Web/staticSites/site"
      default_host_name = "site.azurestaticapps.net"
      api_key           = "mock-api-key"
    }
  }

  mock_resource "azurerm_private_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/endpoints/providers/Microsoft.Network/privateEndpoints/endpoint"
    }
  }
}

mock_provider "modtm" {
  alias = "mocked"
}

mock_provider "random" {
  alias = "mocked"
}

variables {
  name                = "site"
  location            = "eastus2"
  resource_group_name = "site"
  enable_telemetry    = false
  sku_size            = "Standard"
  sku_tier            = "Standard"
}

run "defaults_preserve_endpoint_names_and_static_sites" {
  command = apply

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        ip_configurations = {
          primary = {
            name               = "ipconfig"
            private_ip_address = "10.0.0.4"
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_private_endpoint.this["primary"].name == "pep-site" && one(azurerm_private_endpoint.this["primary"].private_service_connection).name == "pse-site"
    error_message = "Default endpoint and connection names must remain unchanged."
  }

  assert {
    condition     = one(one(azurerm_private_endpoint.this["primary"].private_service_connection).subresource_names) == "staticSites" && one(azurerm_private_endpoint.this["primary"].ip_configuration).member_name == "staticSites" && one(azurerm_private_endpoint.this["primary"].ip_configuration).subresource_name == "staticSites"
    error_message = "Omitted subresource and member names must preserve staticSites."
  }

  assert {
    condition     = length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 0 && length(azurerm_private_endpoint.this["primary"].private_dns_zone_group) == 0 && length(azurerm_management_lock.pe) == 0 && length(azurerm_role_assignment.pe) == 0
    error_message = "Defaults must not create duplicate endpoints, DNS groups, locks or roles."
  }
}

run "managed_dns_honors_supported_settings" {
  command = apply

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    lock = {
      kind = "CanNotDelete"
    }
    private_endpoints = {
      primary = {
        name                            = "endpoint"
        resource_group_name             = "endpoints"
        location                        = "westus2"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        private_service_connection_name = "connection"
        network_interface_name          = "endpoint-nic"
        subresource_name                = "staticSites"
        private_dns_zone_group_name     = "zones"
        private_dns_zone_resource_ids   = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/privateDnsZones/privatelink.azurestaticapps.net"]
        application_security_group_associations = {
          primary = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/applicationSecurityGroups/endpoints"
        }
        lock = {
          kind  = "ReadOnly"
          name  = "endpoint-lock"
          notes = "Endpoint notes"
        }
        role_assignments = {
          reader = {
            name                             = "11111111-1111-1111-1111-111111111111"
            role_definition_id_or_name       = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id                     = "22222222-2222-2222-2222-222222222222"
            description                      = "Endpoint reader"
            skip_service_principal_aad_check = true
            principal_type                   = "ServicePrincipal"
          }
        }
        ip_configurations = {
          primary = {
            name               = "ipconfig"
            private_ip_address = "10.0.0.4"
            member_name        = "custom-member"
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_private_endpoint.this["primary"].name == "endpoint" && azurerm_private_endpoint.this["primary"].resource_group_name == "endpoints" && azurerm_private_endpoint.this["primary"].location == "westus2" && azurerm_private_endpoint.this["primary"].custom_network_interface_name == "endpoint-nic" && one(azurerm_private_endpoint.this["primary"].private_service_connection).name == "connection"
    error_message = "Consumer endpoint names, resource group and location must be honored."
  }

  assert {
    condition     = one(azurerm_private_endpoint.this["primary"].ip_configuration).member_name == "custom-member" && one(azurerm_private_endpoint.this["primary"].ip_configuration).private_ip_address == "10.0.0.4" && one(azurerm_private_endpoint.this["primary"].private_dns_zone_group).name == "zones"
    error_message = "Managed DNS and custom IP configuration settings must be honored."
  }

  assert {
    condition     = azurerm_role_assignment.pe["primary-reader"].name == "11111111-1111-1111-1111-111111111111" && azurerm_role_assignment.pe["primary-reader"].description == "Endpoint reader" && azurerm_role_assignment.pe["primary-reader"].scope == azurerm_private_endpoint.this["primary"].id
    error_message = "Endpoint role names, descriptions and scope must be honored."
  }

  assert {
    condition     = azurerm_management_lock.pe["primary"].lock_level == "ReadOnly" && azurerm_management_lock.pe["primary"].name == "endpoint-lock" && azurerm_management_lock.pe["primary"].notes == "Endpoint notes" && azurerm_management_lock.pe["primary"].scope == azurerm_private_endpoint.this["primary"].id
    error_message = "Explicit endpoint locks must override inheritance and retain their notes."
  }

  assert {
    condition     = azurerm_private_endpoint_application_security_group_association.this["primary-primary"].private_endpoint_id == azurerm_private_endpoint.this["primary"].id && output.resource_private_endpoints["primary"].id == azurerm_private_endpoint.this["primary"].id
    error_message = "Associations and outputs must reference the managed endpoint."
  }
}

run "unmanaged_dns_honors_settings_without_a_parent_lock" {
  command = apply

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      primary = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
        subresource_name              = "staticSites"
        private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/privateDnsZones/privatelink.azurestaticapps.net"]
        application_security_group_associations = {
          primary = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/applicationSecurityGroups/endpoints"
        }
        lock = {
          kind  = "CanNotDelete"
          notes = "Unmanaged endpoint notes"
        }
        role_assignments = {
          reader = {
            name                       = "33333333-3333-3333-3333-333333333333"
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "22222222-2222-2222-2222-222222222222"
            description                = "Unmanaged endpoint reader"
          }
        }
        ip_configurations = {
          primary = {
            name               = "ipconfig"
            private_ip_address = "10.0.0.5"
            member_name        = "custom-member"
          }
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups) == 1 && length(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].private_dns_zone_group) == 0
    error_message = "Unmanaged DNS must use only the existing unmanaged endpoint address and not own a DNS group."
  }

  assert {
    condition     = azurerm_management_lock.pe["primary"].name == "lock-pe-site" && azurerm_management_lock.pe["primary"].lock_level == "CanNotDelete" && azurerm_management_lock.pe["primary"].notes == "Unmanaged endpoint notes"
    error_message = "An explicit lock with no parent or name must work with a stable default name."
  }

  assert {
    condition     = azurerm_role_assignment.pe["primary-reader"].name == "33333333-3333-3333-3333-333333333333" && azurerm_role_assignment.pe["primary-reader"].description == "Unmanaged endpoint reader" && one(azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].ip_configuration).member_name == "custom-member"
    error_message = "Unmanaged endpoints must honor role and member settings."
  }

  assert {
    condition     = azurerm_management_lock.pe["primary"].scope == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].id && azurerm_role_assignment.pe["primary-reader"].scope == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].id && azurerm_private_endpoint_application_security_group_association.this["primary-primary"].private_endpoint_id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].id && output.resource_private_endpoints["primary"].id == azurerm_private_endpoint.this_unmanaged_dns_zone_groups["primary"].id
    error_message = "Unmanaged locks, roles, associations and output must all reference the same endpoint."
  }
}

run "parent_lock_inheritance_preserves_names" {
  command = apply

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    lock = {
      kind = "CanNotDelete"
    }
    private_endpoints = {
      primary = {
        name               = "endpoint"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
    }
  }

  assert {
    condition     = azurerm_management_lock.this[0].name == "lock-site" && azurerm_management_lock.pe["primary"].name == "lock-endpoint" && azurerm_management_lock.pe["primary"].lock_level == "CanNotDelete"
    error_message = "Inherited parent lock kind and default lock names must remain unchanged."
  }
}

run "lock_inheritance_can_be_disabled" {
  command = apply

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    all_child_resources_inherit_lock = false
    private_endpoints_inherit_lock   = false
    lock = {
      kind = "CanNotDelete"
    }
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/endpoints"
      }
    }
  }

  assert {
    condition     = length(azurerm_management_lock.this) == 1 && length(azurerm_management_lock.pe) == 0
    error_message = "Disabling both inheritance flags must leave the endpoint unlocked."
  }
}

run "invalid_subnet_is_rejected" {
  command = plan

  providers = {
    azapi   = azapi.mocked
    azurerm = azurerm.mocked
    modtm   = modtm.mocked
    random  = random.mocked
  }

  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id = "invalid"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}
