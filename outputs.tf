output "invoke_url" {
  value       = module.api.invoke_url
  description = "The URL to invoke the Lambda function."
}

output "lambda_role_id" {
  value       = module.lambda.role_id
  description = "The ID of the role used for the Lambda function."
}
