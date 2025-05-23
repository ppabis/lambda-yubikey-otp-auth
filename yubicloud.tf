resource "aws_secretsmanager_secret" "yubicloud_secret" {
  name                    = "yubicloud_secret"
  description             = "YubiCloud secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "yubicloud_secret_version" {
  secret_id = aws_secretsmanager_secret.yubicloud_secret.id
  secret_string = jsonencode({
    CLIENT_ID  = var.yubicloud_client_id
    SECRET_KEY = var.yubicloud_secret_key
  })
}