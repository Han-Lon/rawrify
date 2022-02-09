"""
    Automated tests for use within GitHub Actions. Meant to verify that previously implemented functions still work
    as expected/weren't impacted by new features.
"""
import requests
import os

if os.environ["branch"] == "prod":
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


# Verify route succeeds
def verify_success(route, url):
    resp = requests.get(url)
    resp_text = resp.text
    if "ERROR" in resp_text.upper():
        raise ValueError(f"{route} check failed!")
    else:
        print(f"{route} check succeeded. Response was {resp_text}")


# TODO add verify_fails for cases that we expect to fail


if __name__ == "__main__":
    print("Beginning checks...")
    for route, url in routes.items():
        verify_success(route, url)
    print("Checks finished.")

