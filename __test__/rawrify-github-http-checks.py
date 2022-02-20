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
routes = {
    "ipv4": f"https://ipv4.{rawrify_domain}/ip",
    # "ipv6": "https://ipv6.rawrify.com/ip", Can't test IPv6 because GitHub self-hosted runners don't support IPv6 at all https://github.com/actions/virtual-environments/issues/668
    "user-agent": f"https://user-agent.{rawrify_domain}/user-agent",
    "b64-encode": f"https://www.{rawrify_domain}/base64?encode=test",
    "b64-decode": f"https://www.{rawrify_domain}/base64?decode=dGVzdA==",
    "temperature": f"https://www.{rawrify_domain}/temperature?latitude=38.8894&longitude=-77.0352"
}

expected_failures = {
    "b64-no-query-strings": f"https://www.{rawrify_domain}/base64",
    "b64-decode-not-base64-encoded": f"https://www.{rawrify_domain}/base64?decode=fail",
    "temperature-no-query-string": f"https://www.{rawrify_domain}/temperature"
}


# Verify route succeeds
def verify_success(route, url):
    resp = requests.get(url)
    resp_text = resp.text
    if "ERROR" in resp_text.upper() or resp.status_code > 399:
        print(f"Testing route {route} resulted in error message: {resp_text}")
        raise ValueError("Check failed!")
    else:
        print(f"{route} check succeeded. Response was {resp_text}")


# Verify expected route failures
def verify_failure(route, url):
    resp = requests.get(url)
    resp_text = resp.text
    if "ERROR" not in resp_text.upper() or resp.status_code < 399:
        print(f"Expected failure {route} resulted in error message: {resp_text}")
    else:
        print(f"Expected failure {route} did not result in error message! Message: {resp_text}")
        raise ValueError("Check failed!")


if __name__ == "__main__":
    print("Beginning checks...")
    for route, url in routes.items():
        verify_success(route, url)
    print("Checks finished.")

