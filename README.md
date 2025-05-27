Lambda Authorizer for Yubikey OTP
==================

In this project we use Lambda Authorizer for API Gateway that authenticates the
user using Yubikey OTP by connecting to YubiCloud. Configure your Client ID,
secret key and press Yubikey on the password field on the authentication form.

Before deploying, you need to install all required libraries to `auth/`. In
Terraform a `null_resource.pip_install` does that for you but it depends on your
system's setup (see `lambda_auth.tf`).

Follow this blog post for more information:

- [https://pabis.eu/blog/2025-06-19-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html](https://pabis.eu/blog/2025-06-19-YubiKey-OTP-Lambda-Authorizer-API-Gateway.html)
