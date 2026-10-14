resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_static_web_app.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    azurerm_static_web_app.this,
    azurerm_private_endpoint.this,
    azurerm_private_endpoint.this_unmanaged_dns_zone_groups,
    azurerm_role_assignment.this,
    azurerm_role_assignment.pe,
    azurerm_private_endpoint_application_security_group_association.this
  ]
}

resource "azurerm_management_lock" "pe" {
  for_each = local.private_endpoint_locks

  lock_level = each.value.kind
  name       = each.value.name
  scope      = local.private_endpoints[each.key].id
  notes      = each.value.notes

  depends_on = [
    azurerm_static_web_app.this,
    azurerm_private_endpoint.this,
    azurerm_private_endpoint.this_unmanaged_dns_zone_groups,
    azurerm_role_assignment.this,
    azurerm_role_assignment.pe,
    azurerm_private_endpoint_application_security_group_association.this
  ]
}
