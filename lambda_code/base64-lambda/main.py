"""
    Lambda for handling base64 conversions from API Gateway.
"""
import os
import base64
from requests_toolbelt.multipart import decoder


def encode_base64(body):
    # Using Payload v1 response format to fool API Gateway into delivering Base64 encoded data as plain text
    # Otherwise, API Gateway completely borks the response

    try:
        encoded_body = base64.b64encode(body.encode("utf-8"))
    except UnicodeDecodeError as e:
        # TODO pick up from here -- see if this works when uploading binary files such as images
        encoded_body = base64.b64encode(body)

    return {'statusCode': 200,
            'headers': {'Content-Type': 'text/plain'},
            'body': encoded_body,
            'isBase64Encoded': False}


def decode_base64(body):
    # Same as encode_base64

    return {'statusCode': 200,
            'headers': {'Content-Type': 'text/plain'},
            'body': base64.b64decode(body),
            'isBase64Encoded': False}


def process_GET_request(query_parameters):
    if "encode" in query_parameters.keys():
        return encode_base64(query_parameters["encode"])
    elif "decode" in query_parameters.keys():
        return decode_base64(query_parameters["decode"])
    else:
        return f'{"ERROR": "Please supply either encode or decode as query strings. Got {query_parameters.keys()}"}'


def process_POST_request(payload):
    if b"encode" in payload.headers[b"Content-Disposition"]:
        return encode_base64(payload.text)
    elif b"decode" in payload.headers[b"Content-Disposition"]:
        return decode_base64(payload.text)
    else:
        return f'{"ERROR": "Please supply either encode or decode as form name. Got {decoded_form[0].headers[b"Content-Disposition"]}"}'


def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

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
        return process_POST_request(decoded_form[0])

    else:
        return f'{{"ERROR": "Request not recognized - {event["rawPath"]}"}}'
