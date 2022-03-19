"""
    Lambda for steganographic functionality in Rawrify
"""
import os
import base64
from requests_toolbelt.multipart import decoder
import io
from stegano import lsb
from PIL import Image


# Embed data into image using Least Significant Bit (LSB) method
def stegano_embed(image, body, format="jpg"):
    # Try converting the user-supplied image to a file-like object
    try:
        bytes_image = io.BytesIO(image)
    except Exception as e:
        return '{"ERROR": "Could not convert image to bytes format. Please ensure your image file is valid."}'

    # Use the Least Significant Bit method of Steganography to hide the user-supplied data
    try:
        secret = lsb.hide(bytes_image, body.decode("utf-8"))
    except Exception as e:
        if "Not a RGB image" in str(e):
            return '{"ERROR": "Please ensure the color scheme of your uploaded image is RGB."}'
        return '{"ERROR": "Could not embed data into image file using Least Significant Bit method."}'

    # Save the generated steganography image to a file-like object
    try:
        secret_bytesIO = io.BytesIO()
        secret.save(secret_bytesIO, format=format)
        secret_bytesIO.seek(0)
    except Exception as e:
        return '{"ERROR": "Could not fully process uploaded image file. Did you use a format other than jpg? If so, you must supply a \'format\' form field."}'

    return {'statusCode': 200,
            'headers': {'Content-Type': 'application/octet-stream'},
            'body': base64.b64encode(secret_bytesIO.getvalue()),
            'isBase64Encoded': True}


# Reveal data from image file embedded using Least Significant Bit (LSB)
def stegano_retrieve(image):
    # Try converting the user-supplied image to a file-like object
    try:
        bytes_image = io.BytesIO(image)
    except Exception as e:
        return '{"ERROR": "Could not convert image to bytes format. Please ensure your image file is valid."}'

    try:
        retrieved = lsb.reveal(bytes_image)
    except Exception as e:
        return '{"ERROR": "Could not retrieve data using Least Significant Bit method. Please check your image."}'

    return {'statusCode': 200,
            'headers': {'Content-Type': 'application/octet-stream'},
            'body': retrieved,
            'isBase64Encoded': False}


# Process encryption requests
def process_request(decoded_form, path):
    resp_dict = dict()
    # Parse the decoded multipart form
    for part in decoded_form:
        # Get what the name of the dictionary should be by doing a few string transformations
        dict_key = part.headers[b"Content-Disposition"].decode("utf-8").split("name=")[1].replace('"', '').split(";")[0]
        resp_dict[dict_key] = part.content
    # Embed or retrieve as needed
    if path == "/steg-embed":
        if all(item in list(resp_dict.keys()) for item in ["image", "body"]):
            return stegano_embed(resp_dict["image"], resp_dict["body"], resp_dict.get("format", b"jpg").decode("utf-8"))
        return f'{{"ERROR": "Please supply form entries named "image" and "body". Got {list(resp_dict.keys())}"}}'

    elif path == "/steg-retrieve":
        if list(resp_dict.keys()) != ["image"]:
            return f'{{"ERROR": "Please supply form entry named "image". Got {list(resp_dict.keys())}"}}'
        return stegano_retrieve(resp_dict["image"])
    else:
        raise ValueError(f"Expected /stegano-embed or /stegano-retrieve path in process_request method, got {path}.")


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    # Handle incorrect MIME type submissions -- only accept multipart/form-data
    if "multipart/form-data" not in event["headers"]["content-type"]:
        return f'{{"ERROR": "Please only supply multipart/form-data MIME type for payload. Received {event["headers"]["content-type"]}"}}'

    if event["rawPath"] == "/steg-embed":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 2 and len(decoded_form) != 3:
            return '{"ERROR": "Please supply these form parameters-- an image file to be packed with data, the message to pack, and an optional format specifier for the image format type"}'
        return process_request(decoded_form, "/steg-embed")

    elif event["rawPath"] == "/steg-retrieve":
        # Read the POST form from the user's request
        decoded_form = decoder.MultipartDecoder(base64.b64decode(event["body"]),
                                                event["headers"]["content-type"]).parts
        # An initial form check-- we have a more robust one within process_request
        if len(decoded_form) != 1:
            return '{"ERROR": "Please supply one form parameter for stegano-retrieve-- an image file with steganographic data"}'
        return process_request(decoded_form, "/steg-retrieve")

    else:
        return f'{{"ERROR": "Request not recognized - {event["rawPath"]}"}}'
