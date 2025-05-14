# Submodules always need to declare providers again
# and  Terraform assumes it is hashicorp/databricks 
# (wrong, because the real Databricks provider is made 
# by Databricks itself, not HashiCorp).
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.40.0"
    }
  }
}