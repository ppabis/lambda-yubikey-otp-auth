resource "null_resource" "pip_install" {
  provisioner "local-exec" {
    command = <<-EOF
    docker run --rm \
     -v ${path.module}/auth:/build \
     amazonlinux:2023 \
     /bin/sh -c 'yum -y install python3-pip; \
     cd /build; \
     pip install -t . -r requirements.txt'
    EOF
    when    = create
  }
  # I disabled the following command because it looks scary but it did not wipe my drive 😅. If you feel confident,
  # use it. If not, delete all directories inside `auth` by yourself.
  #provisioner "local-exec" {
  #  command = "sh -c 'find ${path.module}/auth -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +'"
  #  when    = destroy
  #}
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

resource "aws_iam_role_policy_attachment" "lambda_otp_auth_policy" {
  role       = aws_iam_role.lambda_otp_auth_role.name
  policy_arn = aws_iam_policy.lambda_otp_auth_policy.arn
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