resource "aws_iam_role" "api_gateway_otp_auth_role" {
  name = "ApiGatewayOtpAuthRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "apigateway.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "api_gateway_otp_auth_policy" {
  name = "ApiGatewayOtpAuthPolicy"
  role = aws_iam_role.api_gateway_otp_auth_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "lambda:InvokeFunction"
      Effect   = "Allow"
      Resource = aws_lambda_function.otp_auth.arn
    }]
  })
}

resource "aws_api_gateway_authorizer" "otp_auth" {
  name                             = "otp_auth"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  type                             = "TOKEN"
  authorizer_uri                   = aws_lambda_function.otp_auth.invoke_arn
  authorizer_credentials           = aws_iam_role.api_gateway_otp_auth_role.arn
  authorizer_result_ttl_in_seconds = 60
}

resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  response_type = "UNAUTHORIZED"
  status_code   = "401"

  response_parameters = {
    "gatewayresponse.header.WWW-Authenticate" = "'Basic realm=\"Place OTP in password field\"'"
  }

  response_templates = {
    "text/html" = "<html><body><h1>Unauthorized</h1></body></html>"
  }
}