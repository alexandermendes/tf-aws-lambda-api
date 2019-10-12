output "invoke_url" {
  value       = "${module.api.invoke_url}/${var.path_part}"
  description = "The URL to invoke the Lambda function."
}
