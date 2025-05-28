import boto3, json

dynamodb = boto3.resource("dynamodb")
secretsmanager = boto3.client("secretsmanager")
table = dynamodb.Table("yubikey_otp_auth")

def create_user_secret(public_id: str, private_id: str, key: str):
    secret_name = f"yubikey-otp-{public_id}"
    secret_string = json.dumps({
        "private_id": private_id,
        "key": key
    })
    response = secretsmanager.create_secret(Name=secret_name, SecretString=secret_string)
    return response["ARN"]

def create_user(public_id: str, private_id: str, key: str, name: str):
    secret_arn = create_user_secret(public_id, private_id, key)
    table.put_item(Item={"public_id": public_id, "secret_arn": secret_arn, "usage_counter": 0, "name": name})

if __name__ == "__main__":
    public_id = input("Enter the public ID: ")
    private_id = input("Enter the private ID: ")
    key = input("Enter the key: ")
    name = input("Enter the user's name: ")
    create_user(public_id, private_id, key, name)