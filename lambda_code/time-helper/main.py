from datetime import datetime
import os


# Parse a specific time format supplied by the user
def datetime_formatter(time_dict):
    if "time" not in time_dict.keys():
        return "Error: Expected a time key in the query string paramemter. Please submit request in format /utc-time-now?time=<time_format>"

    time_format = time_dict["time"]
    if time_format == "YYYY-MM-DD":
        return str(datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S"))
    elif time_format == "DD-MM-YYYY":
        return str(datetime.utcnow().strftime("%d-%m-%Y %H:%M:%S"))
    elif time_format == "MM-DD-YYYY":
        return str(datetime.utcnow().strftime("%m-%d-%Y %H:%M:%S"))
    elif time_format == "time-only":
        return str(datetime.utcnow().strftime("%H:%M:%S"))
    else:
        return "Error: Expected a valid time format. Please refer to the wiki for valid time formats."


# Entrypoint for Lambda, start of code execution (after imports)
def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    # User wants current time in UTC
    if event["rawPath"] == "/utc-time-now":
        # If the user submitted a specified time format, process it. If not, return default
        if not event["rawQueryString"]:
            return str(datetime.utcnow())
        else:
            return datetime_formatter(event["queryStringParameters"])
    # User wants the current time in seconds since Unix epoch
    elif event["rawPath"] == "/epoch-now":
        return str(datetime.utcnow().timestamp()).split(".")[0]
    else:
        return f"{{'ERROR': 'Request not recognized - {event['resource']}'}}"

# TODO try using this to implement timezone changing -> https://stackoverflow.com/a/62142178