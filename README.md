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

![rawrify-checks](https://github.com/Han-Lon/rawrify/actions/workflows/rawrify-checks.yml/badge.svg?branch=0.2-dev)

# Rawrify
### An ultra-lightweight general utility API
### Created and maintained by @Han-Lon

## Summary/Intro Videos
- [Rawrify in 5 minutes](https://www.youtube.com/watch?v=OSPcVrEH7Ms)

## What is it?
Simply put, Rawrify is an ultra-lightweight general purpose API that you can use for
things like getting your public IPv4 address, quickly encoding files/strings as base64, and so on.

## How do I use it?
[Refer to the wiki for instructions.](https://github.com/Han-Lon/rawrify/wiki) 
The rest of this README are for the infrastructure and app code that support Rawrify.


## Architecture Diagram
![architecture_diagram](docs/architecture_diagram.svg)


## Feature Roadmap
- v0.3
  - Steganographic functions
  - Asymmetric encryption/decryption
- v0.2
  - Symmetric encryption/decryption
  - Use [CloudFront custom headers](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-cloudfront-headers.html) to add more client-relevant information 
  - Better error handling
  - Fix issue with etag in Terraform code causing unnecessary changes for every apply
  - Add explicit Route53 routes for ipv4 and ipv6 subdomains
- v0.1
  - IPv4, IPv6, and user agent lookup
  - Base64 encoding/decoding
  - Temperature/weather lookup for latitude/longitude location using Weather.gov API
