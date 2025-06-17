# We pick a random region from this list.
locals {
  azure_regions = [
    "westus2",
    "eastus2"
  ]
  azurerm_private_dns_zone_resource_name = "privatelink.${local.reformatted_subdomain}"
  default_host_name                      = module.staticsite.resource_uri
  reformatted_subdomain                  = join(".", slice(local.split_subdomain, 1, length(local.split_subdomain)))
  split_subdomain                        = split(".", local.default_host_name)
}
