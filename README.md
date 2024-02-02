<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-web-staticsite

Module to deploy static web apps in Azure.

 > Note: If you play on deploying a static web app with Terraform, you will need to manually configure the respective YAML file for the GitHub Actions workflow to run.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 0.1.0, < 1.10.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (>= 0.1.0, < 1.10.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azapi_update_resource.this](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azurerm_dns_cname_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) (resource)
- [azurerm_dns_txt_record.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) (resource)
- [azurerm_management_lock.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_static_site.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_site) (resource)
- [azurerm_static_site_custom_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_site_custom_domain) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed. If null, the location will be inferred from the resource group location.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings)

Description:   A map of app settings to assign to the static site.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_branch"></a> [branch](#input\_branch)

Description: The branch of the repository to deploy.

Type: `string`

Default: `null`

### <a name="input_custom_domains"></a> [custom\_domains](#input\_custom\_domains)

Description:   A map of custom domains to assign to the static site.

  - `resource_group_name` - (Optional) The name of the resource group where the custom domain is located. If not set, the resource group of the static site will be used.
  - domain\_name - (Optional) The domain name of the custom domain. If not set, the domain name will be generated from the `cname_name` and `cname_zone_name`.
  - ttl - (Optional) The TTL of the custom domain. Defaults to 300.
  - validation\_type - (Optional) The type of validation to use for the custom domain. Possible values are `cname-delegation` and `dns-txt-token`. Defaults to `cname-delegation`.
  - cname\_name - (Optional) The name of the CNAME record to create for the custom domain.
  - cname\_zone\_name - (Optional) The name of the DNS zone to create the CNAME record in.
  - cname\_record - (Optional) The value of the CNAME record to create for the custom domain. Conflicts with `cname_target_resource_id`.
  - cname\_target\_resource\_id - (Optional) The resource ID of the resource the CNAME record should point to. Conflicts with `cname_record`.
  - txt\_name - (Optional) The name of the TXT record to create for the custom domain.
  - txt\_zone\_name - (Optional) The name of the DNS zone to create the TXT record in.
  - txt\_records - (Optional) A map of TXT records to create for the custom domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `value` - The value of the TXT record.

  ```terraform
  custom_domains = {
    example = {
      resource_group_name = "example"
      domain_name         = "example.com"
      ttl                 = 300
      validation_type     = "cname-delegation"

      cname_name               = "www"
      cname_zone_name          = "example.com"
      cname_record             = "example.azurewebsites.net"
    }
  }
```
  ```
```

Type:

```hcl
map(object({
    resource_group_name = optional(string)
    domain_name         = optional(string)
    ttl                 = optional(number, 300)
    validation_type     = optional(string, "cname-delegation")

    cname_name               = optional(string)
    cname_zone_name          = optional(string)
    cname_record             = optional(string)
    cname_target_resource_id = optional(string)

    txt_name      = optional(string)
    txt_zone_name = optional(string)
    txt_records   = optional(map(object({ value = string })))
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description:   This variable controls whether or not telemetry is enabled for the module.  
  For more information see https://aka.ms/avm/telemetryinfo.  
  If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_identities"></a> [identities](#input\_identities)

Description:   A map used to assign identities to assign to the static site.

  ```terraform
  identities = {
    system = {
      identity_type = "SystemAssigned"
      identity_resource_ids = []
    }
  }
```

Type:

```hcl
map(object({
    identity_type         = optional(string, "SystemAssigned")
    identity_resource_ids = optional(set(string), [])
  }))
```

Default: `{}`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description:   A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
  - `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.
  - `inherit_lock` - (Optional) If set to true, the private endpoint will inherit the lock level of the parent resource. Defaults to true.
  - `inherit_tags` - (Optional) If set to true, the private endpoint will inherit the tags of the parent resource. Defaults to true.

  ```terraform
```

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = optional(string, "None")
    }), {})
    tags                                    = optional(map(any), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
    inherit_lock = optional(bool, true)
    inherit_tags = optional(bool, true)
  }))
```

Default: `{}`

### <a name="input_repository_url"></a> [repository\_url](#input\_repository\_url)

Description: The repository URL of the static site.

Type: `string`

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
  - `condition_version` - The version of the condition syntax. Valid values are '2.0'.
  - delegated\_managed\_identity\_resource\_id - The resource ID of the delegated managed identity resource to assign the role to.

  ```terraform

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
```

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_sku_size"></a> [sku\_size](#input\_sku\_size)

Description: The size of the SKU. The SKU size must be one of: `Free`, `Standard`.

Type: `string`

Default: `"Free"`

### <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier)

Description: The tier of the SKU. The SKU tier must be one of: `Free`, `Standard`.

Type: `string`

Default: `"Free"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description:   A map of tags that will be applied to the Load Balancer.

  ```terraform
  tags = {
    key           = "value"
    "another-key" = "another-value"
    integers      = 123
  }
```

Type: `map(any)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_azurerm_static_site"></a> [azurerm\_static\_site](#output\_azurerm\_static\_site)

Description: This is the full output for the resource.

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_uri"></a> [uri](#output\_uri)

Description: The default hostname of the static site.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->