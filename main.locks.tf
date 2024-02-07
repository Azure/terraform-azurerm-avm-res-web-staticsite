resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_static_site.this.id

  depends_on = [azurerm_static_site.this,
    azurerm_private_endpoint.this,
  azurerm_role_assignment.this]
}

resource "azurerm_management_lock" "pe" {
  for_each = { for private_endpoint, pe_values in var.private_endpoints : private_endpoint => pe_values if((pe_values.inherit_lock && var.lock.kind != "None") || pe_values.lock.kind != "None") }

  lock_level = each.value.inherit_lock ? var.lock.kind : each.value.lock.kind
  name       = each.value.lock.name != null ? each.value.lock.name : (each.value.name != null ? "lock-${each.value.name}" : "lock-pe-${var.name}")
  scope      = azurerm_private_endpoint.this[each.key].id

  depends_on = [
    azurerm_static_site.this,
    azurerm_private_endpoint.this,
    azurerm_role_assignment.this
  ]
}
