provider "google" {
  project = "gitops-platform-akshay-2026"   # your project ID
  region  = "asia-south1"                    # Mumbai
}

resource "google_storage_bucket" "tfstate" {
  name     = "gitops-platform-akshay-2026-tfstate"   # must be GLOBALLY unique
  location = "ASIA-SOUTH1"

  uniform_bucket_level_access = true     # security best practice (no per-object ACLs)
  force_destroy               = false    # don't let an accidental destroy wipe state

  versioning {
    enabled = true                       # recover a deleted/corrupted state — same as S3 versioning
  }
}