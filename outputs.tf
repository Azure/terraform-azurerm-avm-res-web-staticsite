# TODO: insert outputs here.

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "azurerm_static_site" {
  value       = azurerm_static_site.this
  description = "This is the full output for the resource."
}

output "uri" {
  value       = azurerm_static_site.this.default_host_name
  description = "The default hostname of the static site."
}

output "private_endpoints" {
  value       = azurerm_private_endpoint.this
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
}
