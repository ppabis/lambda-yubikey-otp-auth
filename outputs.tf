output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.prod.invoke_url}${var.stage_name}"
}