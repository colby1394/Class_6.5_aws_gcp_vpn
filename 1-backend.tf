terraform {
  backend "s3" {
    bucket  = "change_me" # Name of the S3 bucket
    key     = "aws_to_gcp.tfstate"           # The name of the state file in the bucket
    region  = "us-east-1"                # Use a variable for the region
    encrypt = true                       # Enable server-side encryption (optional but recommended)
  }

  required_providers {
    google = {
      source  = "hashicorp/google",
      version = "~> 6.36.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use latest version if possible

    }

  }
}