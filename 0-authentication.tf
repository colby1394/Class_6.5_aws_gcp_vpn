provider "google" {
  project     = "Change_me"
  region      = "us-central1"
  credentials = "change_me.json"
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "awscc" {
  region  = "us-east-1"
  profile = "default"
}