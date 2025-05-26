
provider "aws" {
  region                   = "us-east-1"
  profile                  = "azarov"
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      owner      = "DA"
      managed_by = "Terraform"
    }
  }
}

