variable "name" {
  description = "The name of the Lambda function."
}

variable "ext" {
  description = "The file extension of the source function."
}

variable "dir" {
  description = "The directory that contains the function."
}

variable "runtime" {
  description = "The identifier of the runtime to use for the function."
}

variable "handler" {
  description = "The function entrypoint in the Lambda function source code."
}

variable "log_retention" {
  description = "Number of days to retain the logs for."
  default     = 30
}

variable "environment" {
  description = "Environment variables for the Lambda function."
  default     = null
  type = object({
    variables = map(string)
  })
}

variable "timeout" {
  description = "The amount of time your Lambda function has to run in seconds."
  default     = 3
}

variable "vpc_config" {
  description = "Provide this to allow your function to access your VPC."
  default     = null
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda function can use at runtime."
  default     = 128
}

variable "http_method" {
  description = "The HTTP method to invoke the Lambda function."
}

variable "enable_cors" {
  description = "Enable CORS for the API Gateway resources."
  default     = false
}

variable "path_part" {
  description = "The last path segment of the API resource."
  default     = "{proxy+}"
}
