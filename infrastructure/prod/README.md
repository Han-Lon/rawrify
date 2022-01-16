## Base64 Functionality
- Encoding operations
  - curl https://RAWRIFY_URL/base64?encode=test
  - curl -X POST -F "encode=@/home/path/to/file" https://RAWRIFY_URL/base64
- Decoding operations
  - curl https://zog9u8kstb.execute-api.us-east-2.amazonaws.com/base64?decode=BASE64_STRING
  - curl -X POST -F "decode=${BASE64_STRING}" https://RAWRIFY_URL/base64
- Using headers has size limit of ~10 KB, using payload has size limit of 10 MB

## Useful reCaptcha links
- https://developers.google.com/recaptcha/intro
- https://github.com/rgfindl/serverless-contact-us-form/blob/master/index.js
- https://github.com/lakshmantgld/aws-lambda-recaptcha