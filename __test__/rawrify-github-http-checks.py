"""
    Automated tests for use within GitHub Actions. Meant to verify that previously implemented functions still work
    as expected/weren't impacted by new features.
"""
import requests
import os

if os.environ["branch"] == "main":
    rawrify_domain = "rawrify.com"
else:
    rawrify_domain = "dev.rawrify.com"

# Dict of routes to check
# SYNTAX
# GET requests: "name@GET": "url"
# POST requests: "name@POST": ["url", "payload"]
routes = {
    "ipv4@GET": f"https://ipv4.{rawrify_domain}/ip",
    # "ipv6": "https://ipv6.rawrify.com/ip", Can't test IPv6 because GitHub self-hosted runners don't support IPv6 at all https://github.com/actions/virtual-environments/issues/668
    "user-agent@GET": f"https://user-agent.{rawrify_domain}/user-agent",
    "b64-encode@GET": f"https://www.{rawrify_domain}/base64?encode=test",
    "b64-decode@GET": f"https://www.{rawrify_domain}/base64?decode=dGVzdA==",
    "temperature@GET": f"https://www.{rawrify_domain}/temperature?latitude=38.8894&longitude=-77.0352",
    "location-country-code@GET": f"https://www.{rawrify_domain}/location?country",
    "location-country-name@GET": f"https://www.{rawrify_domain}/location?country-name",
    "location-city@GET": f"https://www.{rawrify_domain}/location?city",
    "location-coords@GET": f"https://www.{rawrify_domain}/location?coordinates",
    "location-full@GET": f"https://www.{rawrify_domain}/location?full",
    "encryption@POST": [f"https://www.{rawrify_domain}/encrypt", {"KEY": os.environ["ENCRYPTION_KEY"], "MESSAGE": "Test message from CICD"}],
    "decryption@POST": [f"https://www.{rawrify_domain}/decrypt", {"KEY": os.environ["ENCRYPTION_KEY"], "MESSAGE": "gAAAAABiHZeFlMqocfYbNJoRI5bhDQN0QoDfQdDJDPRQM0XUVOdHqMr0v2PydOf8PY9KDDDHpMyNOg_5ouodHDMgek3jCS3MbLnywfXaco7C-Rwau1eE_SU="}]
}

expected_failures = {
    "b64-no-query-strings@GET": f"https://www.{rawrify_domain}/base64",
    "b64-decode-not-base64-encoded@GET": f"https://www.{rawrify_domain}/base64?decode=fail",
    "temperature-no-query-string@GET": f"https://www.{rawrify_domain}/temperature"
}


# Verify route succeeds using GET request
def verify_success(route, url):
    resp = requests.get(url)
    resp_text = resp.text
    if "ERROR" in resp_text.upper() or resp.status_code > 399:
        print(f"Testing route {route} resulted in error message: {resp_text if 'location' not in route else '*****'}")
        raise ValueError("Check failed!")
    else:
        print(f"{route} check succeeded. Response was {resp_text if 'location' not in route else '*****'}")


# Verify expected route failures using GET request
def verify_failure(route, url):
    if route.split("@")[1] == "GET":
        resp = requests.get(url)
    elif route.split("@")[1] == "POST":
        resp = requests.post(url[0], url[1])
    else:
        raise ValueError(f"Expected either GET or POST secondary option for {route}.")
    resp_text = resp.text
    if "ERROR" not in resp_text.upper() or resp.status_code < 399:
        print(f"Expected failure {route} resulted in error message: {resp_text if 'location' not in route else '*****'}")
    else:
        print(f"Expected failure {route} did not result in error message! Message: {resp_text if 'location' not in route else '*****'}")
        raise ValueError("Check failed!")


if __name__ == "__main__":
    print("Beginning checks...")
    for route, url in routes.items():
        verify_success(route, url)
    for route, url in expected_failures.items():
        verify_failure(route, url)
    print("Checks finished.")

