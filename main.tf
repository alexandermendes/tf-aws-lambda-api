locals {
  name = replace(join("-", var.namespace, var.function_name), "/^-/", "")
}

module "lambda" {
  source        = "git::https://github.com/alexandermendes/tf-aws-lambda-file.git?ref=tags/v1.4.0"
  function_name = var.function_name
  namespace     = var.namespace
  ext           = var.ext
  dir           = var.dir
  runtime       = var.runtime
  handler       = var.handler
  log_retention = var.log_retention
  environment   = var.environment
  timeout       = var.timeout
  vpc_config    = var.vpc_config
  memory_size   = var.memory_size
  layers        = var.layers
}

module "api" {
  source            = "./api"
  name              = "${local.name}-api"
  description       = "API to invoke ${local.name}"
  method            = var.http_method
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_name       = module.lambda.name
  enable_cors       = var.enable_cors
}
