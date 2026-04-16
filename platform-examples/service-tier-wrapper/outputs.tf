output "product_contract" {
  value       = module.service.product_contract
  description = "Product-level summary of the service tier wrapper deployment"
}

output "runtime_contract" {
  value       = module.service.runtime_contract
  description = "Remaining runtime inputs controlled by the caller"
}

output "deployment_summary" {
  value       = module.service.deployment_summary
  description = "Consumer-friendly summary of the deployed service"
}

output "sizing_summary" {
  value       = module.service.sizing_summary
  description = "Derived sizing defaults from the selected tier"
}
