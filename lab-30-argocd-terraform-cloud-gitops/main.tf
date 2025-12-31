terraform {
  cloud {
    organization = "<YOUR_TERRAFORM_CLOUD_ORGANIZATION>"

    workspaces {
      name = "<YOUR_TERRAFORM_CLOUD_WORKSPACE_NAME>"
    }
  }
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "random" {}

resource "random_string" "random" {
  length = 16
  special = true
}

output "random_string" {
  value = random_string.random.result
}