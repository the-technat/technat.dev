terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.63.0"
    }
  }
}