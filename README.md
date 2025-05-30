Lambda Authorizer for Yubikey OTP
==================

In this project we use Lambda Authorizer for API Gateway that authenticates the
user using Yubikey OTP.

The version tagged `v1` does it by connecting to YubiCloud. Configure your
Client ID, secret key and press Yubikey on the password field on the
authentication form.

The version tagged `v2` uses custom set OTP. You can create users in the
DynamoDB table using `create_user.py` script. You need to provide then a public
ID, private ID and encryption key that was set in the YubiKey.

Before deploying, you need to install all required libraries to `auth/`. In
Terraform a `null_resource.pip_install` does that for you but it depends on your
system's setup (see `lambda_auth.tf`). For `v2` you will need Docker (unless you
are already running on Amazon Linux 2023).

Follow these blog posts for more information:

- For tag v1:
  - [https://pabis.eu/blog/2025-06-19-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html](https://pabis.eu/blog/2025-06-19-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html)
- For tags v1 and v2:
  - [https://pabis.eu/blog/2025-06-24-Custom-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html](https://pabis.eu/blog/2025-06-24-Custom-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html)
