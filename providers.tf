# Telling Terraform to use the AWS provider from the Hashicorp registry.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# This is the AWS provider configuration. It is telling Terraform to use the AWS provider 
# and to use the credentials in the `~/.aws/credentials` file with the profile `terraform`.
provider "aws" {
  region                   = "us-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terraform"
}
