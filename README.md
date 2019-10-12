# Terraform AWS Lambda API Gateway Module

A Terraform module to create an AWS Lambda resource from file and invoke via API Gateway.

## Usage

For a function `my-function.py` placed in the `functions` directory in the root
of the repository the following snippet will generate a POST endpoint to invoke
that function.

```terraform
module "lambda-api" {
  source      = "git::https://github.com/alexandermendes/tf-aws-lambda-api.git?ref=tags/v1.0.0"
  http_method = "POST"
  name        = "my-function"
  dir         = "functions"
  ext         = "py"
  runtime     = "python3.7"
  handler     = "lambda_handler"

  # Set to "{proxy+}" by default to accept requests to all endpoints
  path_path   = "run"
}
```

**Note that the source reference above is just an example, in most cases you
should update it to the [latest tag](https://github.com/alexandermendes/tf-aws-lambda-api/tags).**

For additional variables and outputs see [variables.tf](./variables.tf) and
[outputs.tf](./outputs.tf), respectively.
