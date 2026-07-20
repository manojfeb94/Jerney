// Terraform GCS backend for Google Cloud Platform
// Replace the placeholder values below or supply them at init

#terraform {
#	backend "gcs" {
		# GCS bucket to store the Terraform state. Create this bucket beforehand.
#		bucket      = "manoj6030-tfstate-bucket"

		# Optional prefix (path) inside the bucket to keep states separated.
#		prefix      = "terraform/state"


#	}
#}
# Usage examples:
# 1) Edit this file and replace values above, then run `terraform init`.
# 2) Prefer not to hardcode sensitive values: run init with backend-config overrides:
#
# terraform init \
#   -backend-config="bucket=jerney-terraform-state" \
#   -backend-config="prefix=terraform/state" \
#   -backend-config="project=jerney-gcp-project" \
#   -backend-config="credentials=/full/path/to/sa.json"

