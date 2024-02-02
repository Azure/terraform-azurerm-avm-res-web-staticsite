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

resource "azapi_update_resource" "this" {
  count = var.repository_url != null ? 1 : 0

  type = "Microsoft.Web/staticSites@2022-03-01"
  body = jsonencode({
    properties = {
      repositoryUrl = var.repository_url
      branch        = var.repository_url != null ? coalesce(var.branch, "main") : null
    }
  })
  resource_id = azurerm_static_site.this.id

  depends_on = [azurerm_static_site.this]
}

resource "azurerm_static_site_custom_domain" "this" {
  for_each = var.custom_domains

  domain_name     = coalesce(each.value.domain_name, "${each.value.cname_name}.${each.value.cname_zone_name}")
  static_site_id  = azurerm_static_site.this.id
  validation_type = each.value.validation_type
}

resource "azurerm_dns_cname_record" "this" {
  for_each = var.custom_domains

  name                = each.value.cname_name
  resource_group_name = coalesce(each.value.resource_group_name, var.resource_group_name)
  ttl                 = each.value.ttl
  zone_name           = each.value.cname_zone_name
  record              = each.value.cname_record
  tags                = var.tags
  target_resource_id  = each.value.cname_target_resource_id
}

resource "azurerm_dns_txt_record" "this" {
  for_each = var.custom_domains

  name                = each.value.txt_name
  resource_group_name = coalesce(each.value.resource_group_name, var.resource_group_name)
  ttl                 = each.value.ttl
  zone_name           = each.value.txt_zone_name
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.txt_records # == null ? [] : ["record"]

    content {
      value = record.value.value
    }
  }
}
