output "name" {
  description = "The name of the static site."
  value       = module.staticsite.name
}

output "resource" {
  description = "The full output of the static site."
  sensitive   = true
  value       = module.staticsite.resource
}

output "resource_id" {
  description = "The resource id of the static site."
  sensitive   = true
  value       = module.staticsite.resource_id
}

output "resource_uri" {
  description = "The default hostname of the static web app."
  value       = module.staticsite.resource_uri
}
