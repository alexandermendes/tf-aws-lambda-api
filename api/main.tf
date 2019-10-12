resource "aws_api_gateway_rest_api" "api" {
  name        = var.name
  description = var.description
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# Requests
resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = var.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "request_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.request_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.lambda_invoke_arn
}

# Responses
resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_integration.request_method_integration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method_response.response_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  response_templates = {
    "application/json" = ""
  }
}

# Enable CORS
# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html
resource "aws_api_gateway_method" "options_method" {
  count         = "${var.enable_cors ? 1 : 0}"
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  count       = "${var.enable_cors ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.options_method[0].http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration" "options_integration" {
  count       = "${var.enable_cors ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.options_method[0].http_method}"

  type             = "MOCK"
  content_handling = "CONVERT_TO_TEXT"

  depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  count       = "${var.enable_cors ? 1 : 0}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.options_method[0].http_method}"
  status_code = "${aws_api_gateway_method_response.options_200[0].status_code}"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,DELETE,GET,HEAD,PATCH,POST,PUT'"
  }

  depends_on = [
    "aws_api_gateway_method_response.options_200",
    "aws_api_gateway_integration.options_integration",
  ]
}

# Depoloyment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on  = [
    "aws_api_gateway_integration.options_integration",
    "aws_api_gateway_integration.request_method_integration",
    "aws_api_gateway_integration_response.response_method_integration"
  ]

  lifecycle {
    create_before_destroy = true
  }

  # Ensure redeployment if the Lambda function has changed
  # https://github.com/hashicorp/terraform/issues/6613
  stage_name        = var.stage_name
  stage_description = "${md5(file("${path.module}/main.tf"))}"
}

# Give API Gateway permissions to invoke the Lambda function
resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = var.lambda_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
  depends_on    = [
    "aws_api_gateway_rest_api.api",
    "aws_api_gateway_resource.proxy"
  ]
}
