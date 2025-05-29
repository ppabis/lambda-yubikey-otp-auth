import re, os, base64
from typing import Tuple
from process_otp import OTP

dynamodb = boto3.resource("dynamodb")
secretsmanager = boto3.client("secretsmanager")
table = dynamodb.Table("yubikey_otp_auth")

def construct_policy(username, event):
  _, _, _, region, accountId, apiGwPath = event['methodArn'].split(':')
  restApiId, stage = apiGwPath.split('/')[:2]
  return {
    'principalId' : username,
    'policyDocument' : {
      'Version' : '2012-10-17',
      'Statement' : [
        {
          'Action': 'execute-api:Invoke',
          'Effect': 'Allow',
          'Resource': [ f"arn:aws:execute-api:{region}:{accountId}:{restApiId}/{stage}/GET/*" ]
        }
      ]
    }
  }

def get_token_from_event(event):
  token = event['authorizationToken']
    if not token:
      raise Exception("Missing Authorization header")
    # From "Basic base64(username:password)", get only "password"
    return base64.b64decode(token.split(' ')[1]).decode('utf-8').split(':')[1]

def get_user_from_database(otp: OTP):
  item = table.get_item(Item={"public_id": otp.public_id})
  if not item:
    raise Exception(f"User {otp.public_id} not found!")
  response = secretsmanager.get_secret_value(SecretId=item['secret_arn'])
  secret = json.loads(response['SecretString'])
  private_id = bytes.fromhex(secret['private_id'])
  key = bytes.fromhex(secret['private_id'])
  if not key or not private_id:
    raise Exception(f"No secret for user {otp.public_id}")
  return private_id, key, item['usage_counter']

def update_usage_counter(otp: OTP):
  table.update_item(Item={"public_id": public_id}, Values={"usage_counter": otp.combined_counter})

def lambda_handler(event, context):
  try:
    token = get_token_from_event(event)
    otp = OTP(token)
    private_id, key, usage_counter = get_user_from_database(otp)
    otp.decrypt(key)
    if otp.validate(private_id, usage_counter):
      policy = construct_policy(otp.public_id, event)
      update_usage_counter(otp)
      return policy
  except Exception as e:
    print(f"Error: {e}")
    raise Exception("Unauthorized")
  raise Exception("Unauthorized")