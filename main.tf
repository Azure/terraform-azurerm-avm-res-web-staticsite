resource "azurerm_static_site" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  dynamic "identity" {
    for_each = var.identities

    content {
      type         = identities.identity_type
      identity_ids = identites.identity_ids
    }
  }

  app_settings = var.app_settings
  tags         = var.tags
}
