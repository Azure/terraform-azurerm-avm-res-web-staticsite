variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
  nullable    = false
}

variable "all_child_resources_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether all child resources should inherit the locks of the parent resource."
}

variable "all_child_resources_inherit_tags" {
  type        = bool
  default     = true
  description = "Whether all child resources should inherit the tags of the parent resource."
}

variable "app_settings" {
  type = map(string)
  default = {

  }
  description = <<DESCRIPTION
  A map of app settings to assign to the static site. 
  
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
  DESCRIPTION
}

variable "basic_auth" {
  type = object({
    password     = string
    environments = string
  })
  default     = null
  description = <<DESCRIPTION
  Object that controls basic authentication access

  ```terraform

  basic_auth = {
    password = "P@55word1234"
    environments = "StagingEnvironment"
  }

  ```
  DESCRIPTION
  sensitive   = true

  validation {
    condition     = var.basic_auth != null ? contains(["AllEnvironments", "StagingEnvironments"], var.basic_auth.environments) : true
    error_message = "Allowed values for `environments`: `AllEnvironments` and `StagingEnvironments`."
  }
}

variable "basic_auth_enabled" {
  type        = bool
  default     = false
  description = "Whether or not basic authentication should be enabled. Needs to be set to `true` in order for `basic_auth` credentials to be evaluated. Defaults to `false`."
}

variable "branch" {
  type        = string
  default     = null
  description = "The branch of the repository to deploy."
}

variable "configuration_file_changes_enabled" {
  type        = bool
  default     = true
  description = "Should changes to the configuration file be permitted? Defaults to `true`."
}

variable "custom_domains" {
  type = map(object({
    resource_group_name = optional(string)
    domain_name         = optional(string)
    ttl                 = optional(number, 300)
    validation_type     = optional(string, "cname-delegation")

    create_cname_records     = optional(bool, false)
    cname_name               = optional(string)
    cname_zone_name          = optional(string)
    cname_record             = optional(string)
    cname_target_resource_id = optional(string)

    create_txt_records = optional(bool, false)
    txt_name           = optional(string)
    txt_zone_name      = optional(string)
    txt_records        = optional(map(object({ value = string })))
  }))
  default = {

  }
  description = <<DESCRIPTION
  A map of custom domains to assign to the static site. 

  - `resource_group_name` - (Optional) The name of the resource group where the custom domain is located. If not set, the resource group of the static site will be used.
  - `domain_name` - (Optional) The domain name of the custom domain. If not set, the domain name will be generated from the `cname_name` and `cname_zone_name`.
  - `ttl` - (Optional) The TTL of the custom domain. Defaults to 300.
  - `validation_type` - (Optional) The type of validation to use for the custom domain. Possible values are `cname-delegation` and `dns-txt-token`. Defaults to `cname-delegation`.
  - `create_cname_records` - (Optional) If set to true, CNAME records will be created for the custom domain. Defaults to false.
  - `create_txt_records` - (Optional) If set to true, TXT records will be created for the custom domain. Defaults to false.
  - `cname_name` - (Optional) The name of the CNAME record to create for the custom domain.
  - `cname_zone_name` - (Optional) The name of the DNS zone to create the CNAME record in.
  - `cname_record` - (Optional) The value of the CNAME record to create for the custom domain. Conflicts with `cname_target_resource_id`.
  - `cname_target_resource_id` - (Optional) The resource ID of the resource the CNAME record should point to. Conflicts with `cname_record`.
  - `txt_name` - (Optional) The name of the TXT record to create for the custom domain.
  - `txt_zone_name` - (Optional) The name of the DNS zone to create the TXT record in.
  - `txt_records` - (Optional) A map of TXT records to create for the custom domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
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
  DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  This variable controls whether or not telemetry is enabled for the module.
  For more information see https://aka.ms/avm/telemetryinfo.
  If it is set to false, then no telemetry will be collected.
  DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "The lock level to apply. Default is `None`. Possible values are `CanNotDelete` and `ReadOnly`."

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: `CanNotDelete` or `ReadOnly`."
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<IDENTITY
An object that sets the managed identity configuration for the virtual machine being deployed. Be aware that capabilities such as the Azure Monitor Agent and Role Assignments require that a managed identity has been configured.

- `system_assigned`            = (Optional) Specifies whether the System Assigned Managed Identity should be enabled.  Defaults to false. 
- `user_assigned_resource_ids` = (Optional) Specifies a set of User Assigned Managed Identity IDs to be assigned to this Virtual Machine.

Example Inputs:
```hcl
#default system managed identity
managed_identities = {
  system_assigned = true
}
#user assigned managed identity only
managed_identities           = {
  user_assigned_resource_ids = ["<azure resource ID of a user assigned managed identity>"]
}
#user assigned and system assigned managed identities
managed_identities  = {
  system_assigned            = true
  user_assigned_resource_ids = ["<azure resource ID of a user assigned managed identity>"]
}
```
IDENTITY
  nullable    = false
}

variable "preview_environments_enabled" {
  type        = bool
  default     = true
  description = " Are Preview (Staging) environments enabled? Defaults to `true`."
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
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
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
  DESCRIPTION
  nullable    = false
}

variable "private_endpoints_inherit_lock" {
  type        = bool
  default     = true
  description = "Whether private endpoints should inherit the lock of the parent resource."
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "repository_url" {
  type        = string
  default     = null
  description = "The repository URL of the static site."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
  - `condition_version` - The version of the condition syntax. Valid values are '2.0'.
  - delegated_managed_identity_resource_id - The resource ID of the delegated managed identity resource to assign the role to.

  ```terraform

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "sku_size" {
  type        = string
  default     = "Free"
  description = "The size of the SKU. The SKU size must be one of: `Free`, `Standard`."

  validation {
    condition     = contains(["Free", "Standard"], var.sku_size)
    error_message = "The SKU size must be one of: 'Free', 'Standard'."
  }
}

variable "sku_tier" {
  type        = string
  default     = "Free"
  description = "The tier of the SKU. The SKU tier must be one of: `Free`, `Standard`."

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "The SKU tier must be one of: 'Free', 'Standard'."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  A map of tags that will be applied to the Static Web App.
  DESCRIPTION
}
