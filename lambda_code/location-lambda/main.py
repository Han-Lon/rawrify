"""
    Lambda for retrieving and returning location-related data. Location
    data is passed by CloudFront, which looks up relevant info based on the
    requester's IP address.

    Note that in some cases, certain geographic elements may be unavailable.
    This can happen occasionally when using services like TOR. Be sure to
    code appropriate logic into your app for handling "None" responses.
"""
import os
import json


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    if event["rawPath"] == "/location":
        if not event["rawQueryString"]:
            return '{"ERROR": "Please supply a valid query string for the /location API (after the URL)."}'

        if len(event["queryStringParameters"].keys()) != 1:
            return f"{{'ERROR': 'Please supply exactly one query string parameter. Got {len(event['queryStringParameters'].keys())}'}}"

        # Instead of adding lots of if, else statements, build the dict (since it's computationally cheap) and retrieve a result given the rawQuerPath
        location_dict = {
            "country": event["headers"].get("cloudfront-viewer-country", None),
            "city": event["headers"].get("cloudfront-viewer-city", None),
            "country-name": event["headers"].get("cloudfront-viewer-country-name", None),
            "coordinates": f"{event['headers'].get('cloudfront-viewer-latitude', None)},{event['headers'].get('cloudfront-viewer-longitude', None)}"
        }
        if event["rawQueryString"] != "full":
            return {'statusCode': 200,
                'headers': {'Content-Type': 'text/plain'},
                'body': location_dict.get(event["rawQueryString"]),
                'isBase64Encoded': False}
        else:
            return {'statusCode': 200,
                    'headers': {'Content-Type': 'text/plain'},
                    'body': json.dumps(location_dict),
                    'isBase64Encoded': False}
    else:
        return f"{{'ERROR': 'Request not recognized - {event['resource']}'}}"