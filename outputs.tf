output "invoke_url" {
  value       = "${module.api.invoke_url}"
  description = "The URL to invoke the Lambda function."
}

output "role_id" {
  value       = module.api.role_id
  description = "The ID of the role used for the Lambda function."
}
