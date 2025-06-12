# We pick a random region from this list.
locals {
  azure_regions = [
    "westus2",
    "centralus",
    "eastus2",
    "westeurope",
    "eastasia"
  ]
}
