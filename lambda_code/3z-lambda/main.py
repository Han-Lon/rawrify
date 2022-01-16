"""
    Lambda for handling the EZPZ requests from API Gateway. These are things
    that can be retrieved easily from the event object passed from API Gateway.
"""
import os


def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    if event["rawPath"] == "/":
        return event["requestContext"]["http"]["sourceIp"]
    elif event["rawPath"] == "/user-agent":
        return event["requestContext"]["http"]["userAgent"]
    else:
        return f"{{'ERROR': 'Request not recognized - {event['resource']}'}}"
