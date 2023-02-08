resource "aws_api_gateway_rest_api" "demoAPI" {
  name = "internal-demo-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "demoAPI" {
  rest_api_id = aws_api_gateway_rest_api.demoAPI.id
  parent_id   = aws_api_gateway_rest_api.demoAPI.root_resource_id
  path_part   = "demo"
}

resource "aws_api_gateway_method" "demoAPI" {
  rest_api_id = aws_api_gateway_rest_api.demoAPI.id
  resource_id = aws_api_gateway_resource.demoAPI.id
  http_method = "GET"
  authorization = "NONE"
  api_key_required = false
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.demoAPI.id
  resource_id             = aws_api_gateway_resource.demoAPI.id
  http_method             = aws_api_gateway_method.demoAPI.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_function_invoke_arn
}

resource "aws_api_gateway_deployment" "demoAPI-deployment" {
  rest_api_id = aws_api_gateway_rest_api.demoAPI.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.demoAPI.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.demoAPI-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.demoAPI.id
  stage_name    = "demo"
}

resource "aws_lambda_permission" "demoAPI" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  source_arn = "${aws_api_gateway_rest_api.demoAPI.execution_arn}/*/*"
}