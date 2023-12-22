resource "azurerm_static_site" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = coalesce(var.location)
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  dynamic "identity" {
    for_each = var.identities

    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_ids
    }
  }

  app_settings = var.app_settings
  tags         = var.tags
}

resource "azapi_update_resource" "example" {
  count = var.repository_url != null ? 1 : 0

  type        = "Microsoft.Web/staticSites@2022-03-01"
  resource_id = azurerm_static_site.this.id
  body = jsonencode({
    properties = {
      repositoryUrl = var.repository_url
      branch        = var.repository_url != null ? coalesce(var.branch, "main") : null
    }
  })
  depends_on = [azurerm_static_site.this]
}

# Custom Domains not yet currently through AVM module

# resource "azurerm_static_site_custom_domain" "this" {
#   for_each = var.custom_domains

#   static_site_id = azurerm_static_site.this.id
#   domain_name = coalesce(each.value.domain_name, "${each.value.cname_name}.${each.value.cname_zone_name}")
#   validation_type = each.value.validation_type  
# }

# resource "azurerm_dns_cname_record" "this" {
#   for_each = var.custom_domains

#   name = each.value.cname_name
#   zone_name = each.value.cname_zone_name
#   resource_group_name = coalesce(each.value.resource_group_name, var.resource_group_name)
#   ttl = each.value.ttl
#   record = each.value.cname_record
#   target_resource_id = each.value.cname_target_resource_id
# }

# resource "azurerm_dns_txt_record" "this" {
#   for_each = var.custom_domains

#   name = each.value.txt_name
#   zone_name = each.value.txt_zone_name
#   resource_group_name = coalesce(each.value.resource_group_name, var.resource_group_name)
#   ttl = each.value.ttl

#   dynamic "record" {
#     for_each = each.value.txt_records

#     content {
#       value = record.value.value
#     }
#   }
# }
