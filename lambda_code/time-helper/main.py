from datetime import datetime
from zoneinfo import ZoneInfo
from zoneinfo import ZoneInfoNotFoundError
import os


# Compare two user-supplied timezones, returning how far ahead or behind timezone1 is to timezone2 (in hours)
def compare_tz(timezone_dict):
    # Check to see that the user-supplied query parameters have a timezone1 key and timezone2 key
    if not all(i in timezone_dict.keys() for i in ["timezone1", "timezone2"]):
        return f"{{'ERROR': 'Expected two query string parameters, timezone1 and timezone2'}}"

    try:
        # Generate datetime objects in the current time for each timezone
        tz1 = datetime.now(tz=ZoneInfo(timezone_dict["timezone1"]))
        tz2 = datetime.now(tz=ZoneInfo(timezone_dict["timezone2"]))
        # Convert from datetime to current hours as an integer, then subtract tz2 from tz1
        timezone1_hours = int(tz1.strftime("%H"))
        timezone2_hours = int(tz2.strftime("%H"))
        tz_comparison = timezone1_hours - timezone2_hours
        # Return result based on comparison
        if tz_comparison > 0:
            return f"Timezone {tz1.tzname()} is {abs(tz_comparison)} hours ahead of timezone {tz2.tzname()}"
        elif tz_comparison < 0:
            return f"Timezone {tz1.tzname()} is {abs(tz_comparison)} hours behind timezone {tz2.tzname()}"
        else:
            return f"Timezone {tz1.tzname()} is equal to timezone {tz2.tzname()}"
    except ZoneInfoNotFoundError as e:
        return f"{{'ERROR': 'Could not parse timezone {str(e)}. Please ensure supplied timezone is valid, cross-reference with https://en.wikipedia.org/wiki/List_of_tz_database_time_zones'}}"


# Get the current time in a specific, user-supplied timezone
def tz_time(timezone_dict):
    if "timezone" not in timezone_dict.keys():
        return f"{{'ERROR': 'Expected a timezone query string parameter. Please add a timezone query string parameter to your request e.g. /get-timezone-time?timezone=<your_target_timezone>'}}"

    try:
        timezone = timezone_dict["timezone"]
        return str(datetime.now(tz=ZoneInfo(timezone)))
    except ZoneInfoNotFoundError as e:
        return f"{{'ERROR': 'Could not parse timezone. Please ensure supplied timezone is valid, cross-reference with https://en.wikipedia.org/wiki/List_of_tz_database_time_zones'}}"


# Parse a specific time format supplied by the user
def datetime_formatter(time_dict):
    if "time" not in time_dict.keys():
        return "Error: Expected a time key in the query string paramemter. Please submit request in format /utc-time-now?time=<time_format>"

    time_format = time_dict["time"]
    # Only support a set of predefined datetime formats because I'm paranoid and don't want users passing in custom formatting parameters (a la the somewhat recent Log4J vulnerability)
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
    elif event["rawPath"] == "/get-timezone-time":
        if not event["rawQueryString"]:
            return f"{{'ERROR': 'Expected a query string with the get-tz-time request. Please add a query string, such as /get-timezone-time?timezone=<your_target_timezone>'}}"
        return tz_time(event["queryStringParameters"])
    elif event["rawPath"] == "/compare-timezones":
        if not event["rawQueryString"]:
            return f"{{'ERROR': 'Expected a query string with the compare-timezones request. Please add a query string with two timezones, e.g. /compare-timezones?timezone1=<...>&timezone2=<...>'}}"
        return compare_tz(event["queryStringParameters"])
    else:
        return f"{{'ERROR': 'Request not recognized - {event['resource']}'}}"
