module "lambda" {
  source        = "git::https://github.com/alexandermendes/tf-aws-lambda-file.git?ref=tags/v1.2.0"
  name          = var.name
  ext           = var.ext
  dir           = var.dir
  runtime       = var.runtime
  handler       = var.handler
  log_retention = var.log_retention
  environment   = var.environment
  timeout       = var.timeout
  vpc_config    = var.vpc_config
  memory_size   = var.memory_size
}

module "api" {
  source            = "./api"
  name              = "${var.name}-api"
  description       = "API to invoke ${var.name}"
  method            = var.http_method
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_name       = module.lambda.name
}
