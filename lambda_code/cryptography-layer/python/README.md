## To build cryptography for AWS Lambda
- You will get _cffi-backend errors if you don't build with the proper architecture and version of Python
- Spin up a very small EC2 instance using Ubuntu 18.04 LTS with ARM architecture (NOT x86_64)
- Follow these commands to install Python 3.8 (or your version of Python) https://linuxize.com/post/how-to-install-python-3-8-on-ubuntu-18-04/
  - MUST BE THE SAME VERSION OF PYTHON AS THE LAMBDA
- `python3.8 -m venv venv`
- `source ./venv/bin/activate`
- `pip install cryptography`
- `deactivate`
- SFTP the cryptography files off the server