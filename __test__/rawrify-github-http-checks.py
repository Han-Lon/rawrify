"""
    Automated tests for use within GitHub Actions. Meant to verify that previously implemented functions still work
    as expected/weren't impacted by new features.
"""
import requests


# Dict of routes to check
routes = {
    "ipv4": "https://ipv4.rawrify.com/ip",
    "ipv6": "https://ipv6.rawrify.com/ip",
    "user-agent": "https://user-agent.rawrify.com/user-agent",
    "b64-encode": "https://www.rawrify.com/base64?encode=test",
    "b64-decode": "https://www.rawrify.com/base64?decode=dGVzdA==",
    "temperature": "https://www.rawrify.com/temperature?latitude=38.8894&longitude=-77.0352"
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

