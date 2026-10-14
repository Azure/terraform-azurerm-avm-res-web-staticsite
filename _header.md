# terraform-azurerm-avm-res-web-staticsite

Module to deploy Static Web Apps in Azure.

Private endpoints default to the `staticSites` subresource and IP configuration member. Endpoint-specific locks override inherited locks; omitting an endpoint lock inherits the parent lock when either lock-inheritance option is enabled. Role assignment names and descriptions, lock notes, and IP configuration member names are honored in both DNS-management modes. `resource_private_endpoints` includes endpoints with externally managed DNS zone groups.

 > Note: After the Static Site is provisioned, you'll need to associate your target repository, which contains your web app, to the Static Site, by following the Azure Static Site document. This includes manually configuring the respective YAML file for the GitHub Actions workflow to run.
