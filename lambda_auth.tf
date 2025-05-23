resource "null_resource" "pip_install" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/auth/requirements.txt -t ${path.module}/auth/"
    when    = create
  }
}

resource "archive_file" "authorizer_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/auth"
  output_path = "${path.module}/authorizer.zip"

  depends_on = [null_resource.pip_install]
}

resource "aws_iam_role" "lambda_otp_auth_role" {
  name = "LambdaOtpAuthRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_otp_auth_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "yubicloud_secret_access" {
  name = "LambdaOtpAuthPolicy"
  role = aws_iam_role.lambda_otp_auth_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "secretsmanager:GetSecretValue"
      Effect = "Allow"
      Resource = aws_secretsmanager_secret.yubicloud_secret.arn
    }]
  })
}

resource "aws_lambda_function" "otp_auth" {
  function_name    = "otp_auth"
  role             = aws_iam_role.lambda_otp_auth_role.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.12"
  timeout          = 15
  memory_size      = 128
  architectures    = ["arm64"]
  filename         = archive_file.authorizer_lambda.output_path
  source_code_hash = archive_file.authorizer_lambda.output_base64sha256
}