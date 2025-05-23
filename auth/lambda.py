import re, yubico_client, os, base64
from typing import Tuple
from secret import get_secret_manager_secret

secret = get_secret_manager_secret('yubicloud_secret')
client = yubico_client.Yubico(secret['CLIENT_ID'], secret['SECRET_KEY'])

def validate_otp(otp) -> bool:
  """Validate the OTP key using YubiCloud API"""
  try:
    response = client.verify(otp)
    return True if response is True else False # Normalize in case it is None or anything unexpected
  except Exception as e:
    print(f"Error validating OTP: {e}")
    return False

def authenticate(token) -> Tuple[str, bool]:
  """Authenticate the user using the OTP key. Returns tuple of public ID and if OTP is valid"""
  if not token:
    raise Exception("Missing Authorization header")
  
  # From "Basic base64(username:password)", get only "password"
  otp = base64.b64decode(token.split(' ')[1]).decode('utf-8').split(':')[1]
  
  if not re.match(r'^[cbdefghijklnrtuv]{44}$', otp):
    raise Exception("Invalid OTP format")
  
  return otp[:12], validate_otp(otp)

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

def lambda_handler(event, context):
  try:
    username, valid = authenticate(event['authorizationToken'])
    if valid:
      policy = construct_policy(username, event)
      return policy
  except Exception as e:
    print(f"Error: {e}")
    raise Exception("Unauthorized")
  raise Exception("Unauthorized")