######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  Terraform state file declaration for remote S3 backend
*/

terraform {
  backend "s3" {
    bucket = "rawrify-state-bucket"
    key = "rawrify-prod-state.tstate"
    region = "us-east-2"
    profile = "rawrify-prod"
  }
}