resource "aws_api_gateway_integration" "static-site" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.get.http_method
  type        = "MOCK"

  request_templates = {
    "text/html"        = jsonencode({ statusCode = 200 })
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "static" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
  response_models = {
    "text/html" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "static" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_templates = {
    "text/html" = file("${path.module}/static-site.html")
  }

  depends_on = [aws_api_gateway_integration.static-site]
}