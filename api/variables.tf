variable "name" {
  description = "The name of the REST API"
}

variable "description" {
  description = "A description for the API"
  default     = ""
}

variable "method" {
  description = "The HTTP method."
}

variable "lambda_name" {
  description = "The Lambda function name"
}

variable "lambda_invoke_arn" {
  description = "The Lambda invoke ARN."
}

variable "enable_cors" {
  description = "Enable CORS for the API Gateway resources."
}

variable "stage_name" {
  description = "The name of the stage."
  default     = "dev"
}

variable "path_part" {
  description = "The last path segment of the API resource."
}