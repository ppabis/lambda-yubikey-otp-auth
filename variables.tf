variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
  default     = "prod"
}

variable "yubicloud_secret_key" {
  type        = string
  description = "YubiCloud secret key (set as environment variable!)"
  sensitive   = true
}

variable "yubicloud_client_id" {
  type        = string
  description = "YubiCloud client ID"
}