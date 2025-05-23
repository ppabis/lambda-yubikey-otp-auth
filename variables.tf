variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
  default     = "prod"
}