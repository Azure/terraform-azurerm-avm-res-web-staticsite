/*
resource "azurerm_static_site" "this" {
  location            = coalesce(var.location)
  name                = var.name
  resource_group_name = var.resource_group_name
  app_settings        = var.app_settings
  sku_size            = var.sku_size
  sku_tier            = var.sku_tier
  tags                = var.tags

  dynamic "identity" {
    for_each = var.identities # == null ? [] : ["identity"]

    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_resource_ids
    }
  }
}
*/

# /*
# BREAKING CHANGE 
resource "azurerm_static_web_app" "this" {
  location            = coalesce(var.location)
  name                = var.name
  resource_group_name = var.resource_group_name
  app_settings        = var.app_settings
  sku_size            = var.sku_size
  sku_tier            = var.sku_tier
  tags                = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_resource_ids
    }
  }
}
# */

resource "azapi_update_resource" "this" {
  count = var.repository_url != null ? 1 : 0

  type = "Microsoft.Web/staticSites@2022-03-01"
  body = jsonencode({
    properties = {
      repositoryUrl = var.repository_url
      branch        = coalesce(var.branch, "main")
    }
  })
  # resource_id = azurerm_static_site.this.id
  resource_id = azurerm_static_web_app.this.id # BREAKING CHANGE

  depends_on = [
    azurerm_static_web_app.this
  ] # BREAKING CHANGE
}
