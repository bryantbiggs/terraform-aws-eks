terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2.0"
    }
  }
}
