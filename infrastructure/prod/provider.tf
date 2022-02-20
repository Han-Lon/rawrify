######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  Define Terraform providers for AWS and retrieve some helpful data sources
*/

provider "aws" {
  region = "us-east-2"
  profile = var.env == "prod" ? "rawrify-prod" : "rawrify-dev"
  allowed_account_ids = var.env == "prod" ? [var.prod_account_id] : [var.dev_account_id]
}

# Needed because of some bullcrap where Route53 A record aliases ONLY work if your Cloudfront distribution is in us-east-1 fml
provider "aws" {
  alias = "aws-us-east-1"
  region = "us-east-1"
  profile = var.env == "prod" ? "rawrify-prod" : "rawrify-dev"
  allowed_account_ids = var.env == "prod" ? [var.prod_account_id]: [var.dev_account_id]
}

# Needed to reference AWS account ID in the default aws provider block
data "aws_caller_identity" "default-provider-account-id" {
  provider = aws
}

# Needed to reference AWS account ID in the default aws provider block
data "aws_region" "default-provider-region" {
  provider = aws
}