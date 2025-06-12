resource "azurerm_static_web_app" "this" {
  location                           = coalesce(var.location)
  name                               = var.name
  resource_group_name                = var.resource_group_name
  app_settings                       = var.app_settings
  configuration_file_changes_enabled = var.configuration_file_changes_enabled
  preview_environments_enabled       = var.preview_environments_enabled
  public_network_access_enabled      = var.public_network_access_enabled
  sku_size                           = var.sku_size
  sku_tier                           = var.sku_tier
  tags                               = var.tags

  dynamic "basic_auth" {
    for_each = var.basic_auth_enabled ? ["basic_auth"] : []

    content {
      environments = var.basic_auth.environments
      password     = var.basic_auth.password
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  lifecycle {
    ignore_changes = [
      repository_url,
      repository_branch
    ]
  }
}

resource "azapi_update_resource" "this" {
  count = var.repository_url != null ? 1 : 0

  resource_id = azurerm_static_web_app.this.id
  type        = "Microsoft.Web/staticSites@2022-03-01"
  body = {
    properties = {
      repositoryUrl = var.repository_url
      branch        = coalesce(var.branch, "main")
    }
  }

  depends_on = [
    azurerm_static_web_app.this
  ]
}
