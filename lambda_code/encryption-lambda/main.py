"""
    Lambda for handling basic encryption from API Gateway

    TODO remove the below statement from here and add to doc
    KEY=`openssl rand -base64 32`
    curl -X POST -F "key=$KEY" -F "body=TEST" https://www.dev.rawrify.com/encrypt
"""
import os
import base64
from requests_toolbelt.multipart import decoder
from cryptography.fernet import Fernet


# TODO this handles symmetric encryption. Consider implementing asymmetric encryption as well.

# Encrypt using Python's Fernet library (within cryptography)
def encrypt(key, body):
    try:
        f = Fernet(key)
    except Exception as e:
        return '{"ERROR": "Could not import key. Please ensure your key adheres to the 32-bit standard required by Python Fernet."}'
    return {'statusCode': 200,
            'headers': {'Content-Type': 'text/plain'},
            'body': f.encrypt(body),
            'isBase64Encoded': False}


# Decrypt using Python's Fernet library (within cryptography)
def decrypt(key, body):
    try:
        f = Fernet(key)
    except Exception as e:
        return '{"ERROR": "Could not import key. Please ensure your key adheres to the 32-bit standard required by Python Fernet."}'

# TODO troubleshoot why this try/except block isn't catching InvalidToken decryption messages
    try:
        decrypted_body = f.decrypt(body)
    except Exception as e:
        print(str(e))
        if "InvalidToken" in str(e):
            return '{"ERROR": "Could not decrypt encrypted message with this key. Check the key you provided and try again."}'
        else:
            raise

    return {'statusCode': 200,
            'headers': {'Content-Type': 'text/plain'},
            'body': decrypted_body,
            'isBase64Encoded': False}


# Process encryption requests
def process_request(decoded_form, path):
    resp_dict = dict()
    # Parse the decoded multipart form
    for part in decoded_form:
        # Get what the name of the dictionary should be by doing a few string transformations
        dict_key = part.headers[b"Content-Disposition"].decode("utf-8").split("name=")[1].replace('"', '').split(";")[0]
        resp_dict[dict_key] = part.content
    # Make sure the user submitted a key and body, nothing more and nothing less
    if list(resp_dict.keys()) != ["key", "body"]:
        return f'{{"ERROR": "Please supply form entries named "key" and "body". Got {list(resp_dict.keys())}"}}'
    # Encrypt or decrypt as needed
    if path == "/encrypt":
        return encrypt(resp_dict["key"], resp_dict["body"])
    elif path == "/decrypt":
        return decrypt(resp_dict["key"], resp_dict["body"])
    else:
        raise ValueError(f"Expected /encrypt or /decrypt path in process_request method, got {path}.")


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    if event["rawPath"] == "/encrypt":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 2:
            return '{"ERROR": "Please supply two form parameters-- a 32-bit private key and a message to be encrypted."}'
        return process_request(decoded_form, "/encrypt")

    elif event["rawPath"] == "/decrypt":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 2:
            return '{"ERROR": "Please supply two form parameters-- a 32-bit private key and a message to be encrypted"}'
        return process_request(decoded_form, "/decrypt")

    else:
        return f'{{"ERROR": "Request not recognized - {event["rawPath"]}"}}'
