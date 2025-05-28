resource "aws_dynamodb_table" "yubikey_otp_auth" {
  name         = "yubikey_otp_auth"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "public_id"
  attribute {
    name = "public_id"
    type = "S"
  }
}