"""
    Asymmetric (public+private key) encryption and decryption through Rawrify

    Big thanks to https://nitratine.net/blog/post/asymmetric-encryption-and-decryption-in-python/
"""
import os
import base64
from requests_toolbelt.multipart import decoder
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.asymmetric import padding


# Encrypt using asymmetric encryption functionality within Python Cryptography
def encrypt(key, body):
    try:
        public_key = serialization.load_pem_public_key(
            key,
            backend=default_backend()
        )
    except Exception as e:
        return '{"ERROR": "Could not import key. Please ensure you\'re using the appropriate PUBLIC key."}'

    try:
        ciphertext = public_key.encrypt(
            body,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    except Exception as e:
        return '{"ERROR": "Error encrypting your message with the public key."}'
    return {'statusCode': 200,
            'headers': {'Content-Type': 'application/octet-stream'},
            'body': base64.b64encode(ciphertext),
            'isBase64Encoded': True}


# Decrypt using asymmetric decryption functionality within Python Cryptography
def decrypt(key, body):
    try:
        private_key = serialization.load_pem_private_key(
            key,
            password=None,
            backend=default_backend()
        )
    except Exception as e:
        return '{"ERROR": "Could not import private key. Please ensure you\'re using the appropriate PRIVATE key."}'

    # Catch block here in case decryption key is invalid/wrong key
    try:
        deciphertext = private_key.decrypt(
            body,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
    except Exception as e:
            return '{"ERROR": "Could not decrypt encrypted message with this key. Check the key you provided and try again."}'

    return {'statusCode': 200,
            'headers': {'Content-Type': 'application/octet-stream'},
            'body': base64.b64encode(deciphertext),
            'isBase64Encoded': True}


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
    if path == "/asymmetric-encrypt":
        return encrypt(resp_dict["key"], resp_dict["body"])
    elif path == "/asymmetric-decrypt":
        return decrypt(resp_dict["key"], resp_dict["body"])
    else:
        raise ValueError(f"Expected /asymmetric-encrypt or /asymmetric-decrypt path in process_request method, got {path}.")


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    # Handle incorrect MIME type submissions -- only accept multipart/form-data
    if "multipart/form-data" not in event["headers"]["content-type"]:
        return f'{{"ERROR": "Please only supply multipart/form-data MIME type for payload. Received {event["headers"]["content-type"]}"}}'

    if event["rawPath"] == "/asymmetric-encrypt":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 2:
            return '{"ERROR": "Please supply two form parameters-- a 32-bit private key and a message to be encrypted."}'
        return process_request(decoded_form, "/asymmetric-encrypt")

    elif event["rawPath"] == "/asymmetric-decrypt":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 2:
            return '{"ERROR": "Please supply two form parameters-- a 32-bit private key and a message to be encrypted"}'
        return process_request(decoded_form, "/asymmetric-decrypt")

    else:
        return f'{{"ERROR": "Request not recognized - {event["rawPath"]}"}}'
