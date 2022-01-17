import requests
import os

# Easy way to get latitude/longitude quickly https://developers.google.com/maps/documentation/geocoding/overview
# Format for querying


def lambda_handler(event, context):
    print(event) if os.getenv("ENV", None) == "dev" else None

    if event["rawPath"] == "/temperature":
        if not event["rawQueryString"]:
            return '{"ERROR": "Please supply two query string parameters-- a latitude and longitude."}'
        if len(event["queryStringParameters"].keys()) != 2 or list(event["queryStringParameters"]) != ["latitude", "longitude"]:
            return '{"ERROR": "Please supply two query string parameters: a latitude and a longitude"}'

        try:
            metadata = requests.get(f"https://api.weather.gov/points/{round(float(event['queryStringParameters']['latitude']), 4)},{round(float(event['queryStringParameters']['longitude']), 4)}")
            forecastHourly = requests.get(metadata.json()["properties"]["forecastHourly"]).json()
            currentTemperature = f'{forecastHourly["properties"]["periods"][0]["temperature"]}{forecastHourly["properties"]["periods"][0]["temperatureUnit"]}'
            return currentTemperature
        except ValueError as e:
            return f"{{'ERROR': 'Please check your latitude and longitude coordinates. Ran into error converting to float.'}}"
    else:
        return f"{{'ERROR': 'Request not recognized - {event['rawPath']}'}}"