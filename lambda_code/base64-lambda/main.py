"""
    Lambda for handling base64 conversions from API Gateway.
"""
import os
import base64
from requests_toolbelt.multipart import decoder


# Encode a string or file as Base64 and return the encoded string to the client
def encode_base64(body):
    # Using Payload v1 response format to fool API Gateway into delivering Base64 encoded data as plain text
    # Otherwise, API Gateway completely borks the response

    if type(body) == str:
        body = body.encode("utf-8")

    encoded_body = base64.b64encode(body)

    return {'statusCode': 200,
            'headers': {'Content-Type': 'text/plain'},
            'body': encoded_body,
            'isBase64Encoded': False}


# Decode a Base64 encoded string and return a proper dictionary for returning to client
def decode_base64(body):
    # Same as encode_base64
    return {'statusCode': 200,
            'headers': {'Content-Type': 'application/octet-stream'},
            'body': body,
            'isBase64Encoded': True}


# Process GET requests, which require different logic from POST requests
def process_GET_request(query_parameters):
    if "encode" in query_parameters.keys():
        return encode_base64(query_parameters["encode"])
    elif "decode" in query_parameters.keys():
        return decode_base64(query_parameters["decode"])
    else:
        return f'{"ERROR": "Please supply either encode or decode as query strings. Got {query_parameters.keys()}"}'


# Process POST requests, which require different logic from GET requests
def process_POST_request(headers, payload):
    if b"encode" in headers[b"Content-Disposition"]:
        return encode_base64(payload)
    elif b"decode" in headers[b"Content-Disposition"]:
        return decode_base64(payload)
    else:
        return f'{"ERROR": "Please supply either encode or decode as form name. Got {payload.headers[b"Content-Disposition"]}"}'


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    # Determine type of request-- POST or GET
    if event["rawPath"] == "/base64" and event["requestContext"]["http"]["method"] == "GET":
        if not event["rawQueryString"]:
            return '{"ERROR": "Please supply either encode or decode as query string parameters after the URL."}'
        if len(event["queryStringParameters"].keys()) != 1:
            return '{"ERROR": "Please supply only one encode or decode query string parameter per request."}'
        return process_GET_request(event["queryStringParameters"])

    elif event["rawPath"] == "/base64" and event["requestContext"]["http"]["method"] == "POST":
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]), event["headers"]["content-type"]).parts
        if len(decoded_form) != 1:
            return '{"ERROR": "Please supply only one encode or decode form per request."}'
        for part in decoded_form:
            return process_POST_request(part.headers, part.content)

    else:
        return f'{{"ERROR": "Request not recognized - {event["rawPath"]}"}}'
