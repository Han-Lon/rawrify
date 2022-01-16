    #######################################
     _____                     _  __
    |  __ \                   (_)/ _|
    | |__) |__ ___      ___ __ _| |_ _   _
    |  _  // _` \ \ /\ / / '__| |  _| | | |
    | | \ \ (_| |\ V  V /| |  | | | | |_| |
    |_|  \_\__,_| \_/\_/ |_|  |_|_|  \__, |
                                      __/ |
                                     |___/
    #######################################

# Rawrify (Work-In-Progress)
### An ultra-lightweight general utility API
### Created and maintained by @Han-Lon

## What is it?
Simply put, Rawrify is an ultra-lightweight general purpose API that you can use for
things like getting your public IPv4 address, quickly encoding files/strings as base64, and so on.

## What can it do? (Current State)
- Retrieve your public IPv4 or IPv6 address
- Quickly encode or decode text and files as Base64 strings
- Retrieve your current user agent

## How do I use it?
### IPv4, IPv6, and user-agent lookup
- IPv4 - https://ipv4.rawrify.com/
  - e.g. ```curl https://ipv4.rawrify.com/```
- IPv6 - https://ipv6.rawrify.com/
  - e.g. ```curl https://ipv6.rawrify.com/```
- User Agent - https://www.rawrify.com/user-agent/
  - e.g. ```curl https://www.rawrify.com/user-agent/```

### Base64 Encoding/Decoding
- Two methods, using GET with URL parameters or POST with form data
- GET method (~10 KB size limit, less secure)
  - Encoding ```curl https://www.rawrify.com/base64?encode=TEST_STRING```
  - Decoding ```curl curl https://www.rawrify.com/base64?decode=BASE64_STRING```
- POST method (~10 MB size limit, more secure)
  - Encoding
    - string: ```curl -X POST -F "encode=TEST_STRING" https://www.rawrify.com/base64```
    - file: ```curl -X POST -F "encode=@/home/path/to/file" https://www.rawrify.com/base64```
  - Decoding
    - string: ```curl -X POST -F "decode=BASE64_STRING" https://www.rawrify.com/base64```
    - file: ```curl -X POST -F "decode=@/home/path/to/base64file" https://www.rawrify.com/base64```

## Feature Roadmap
- v0.3 (TBD)
  - Basic encryption/decryption (maybe), will function similar to Base64 encoding but with an encryption key
  - Temperature/weather lookup for latitude/longitude location using Weather.gov API
- v0.2
  - IPv4, IPv6, and user agent lookup
  - Base64 encoding/decoding