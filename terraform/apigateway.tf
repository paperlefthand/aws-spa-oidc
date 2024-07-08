resource "aws_apigatewayv2_api" "api" {
  api_key_selection_expression = "$request.header.x-api-key"
  body                         = null
  credentials_arn              = null
  description                  = null
  disable_execute_api_endpoint = false
  fail_on_warnings             = null
  name                         = var.project
  protocol_type                = "HTTP"
  route_key                    = null
  route_selection_expression   = "$request.method $request.path"
  tags                         = {}
  tags_all                     = {}
  target                       = null
  version                      = null
  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age           = 300
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  auto_deploy = true
  name        = var.env
}

resource "aws_apigatewayv2_authorizer" "authorizer_get" {
  api_id                            = aws_apigatewayv2_api.api.id
  authorizer_credentials_arn        = null
  authorizer_payload_format_version = null
  authorizer_result_ttl_in_seconds  = 0
  authorizer_type                   = "JWT"
  authorizer_uri                    = null
  enable_simple_responses           = false
  identity_sources                  = ["$request.header.Authorization"]
  name                              = var.project
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

resource "aws_apigatewayv2_route" "route_option" {
  api_id                              = aws_apigatewayv2_api.api.id
  api_key_required                    = false
  authorization_scopes                = []
  authorization_type                  = "NONE"
  authorizer_id                       = null
  model_selection_expression          = null
  operation_name                      = null
  request_models                      = {}
  route_key                           = "OPTIONS /${var.project}"
  route_response_selection_expression = null
  target                              = null
}

resource "aws_apigatewayv2_route" "route_get" {
  api_id                              = aws_apigatewayv2_api.api.id
  api_key_required                    = false
  authorization_scopes                = []
  authorization_type                  = "JWT"
  authorizer_id                       = aws_apigatewayv2_authorizer.authorizer_get.id
  model_selection_expression          = null
  operation_name                      = null
  request_models                      = {}
  route_key                           = "GET /${var.project}"
  route_response_selection_expression = null
  target                              = "integrations/${aws_apigatewayv2_integration.integration_get.id}"
}

resource "aws_apigatewayv2_integration" "integration_get" {
  api_id                        = aws_apigatewayv2_api.api.id
  connection_id                 = null
  connection_type               = "INTERNET"
  content_handling_strategy     = null
  credentials_arn               = null
  description                   = null
  integration_method            = "POST"
  integration_subtype           = null
  integration_type              = "AWS_PROXY"
  integration_uri               = aws_lambda_function.main.arn
  passthrough_behavior          = null
  payload_format_version        = "2.0"
  request_parameters            = {}
  request_templates             = {}
  template_selection_expression = null
  timeout_milliseconds          = 30000
}

# API GatewayによるLambdaのinvoke許可
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/${aws_apigatewayv2_stage.stage.name}/*"
}