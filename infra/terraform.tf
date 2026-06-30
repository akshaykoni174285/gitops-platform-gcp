terraform {
  required_version = ">=1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket  = "gitops-platform-akshay-2026-tfstate"
    prefix  = "infra"
  }
}