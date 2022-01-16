terraform {
  backend "s3" {
    bucket = "rawrify-prod-state-bucket"
    key = "rawrify-prod-state.tstate"
    region = "us-east-2"
  }
}