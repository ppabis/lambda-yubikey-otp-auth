data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_otp_auth_policy" {
  statement {
    actions = [
        "dynamodb:UpdateItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.yubikey_otp_auth.arn]
  }
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:yubikey-otp-*"
    ]
  }  
}

resource "aws_iam_policy" "lambda_otp_auth_policy" {
  name   = "LambdaOtpAuthPolicy"
  policy = data.aws_iam_policy_document.lambda_otp_auth_policy.json
}