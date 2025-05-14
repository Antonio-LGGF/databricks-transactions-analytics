provider "aws" {
  region = var.aws_region
}

#####################################
# S3
#####################################

module "s3_bucket" {
  source = "./S3"
  # variables:
  bucket_name = local.s3_bucket_name
  tags        = var.tags
}


#####################################
# databricks
#####################################

module "databricks" {
  source = "./databricks" # Folder where your Databricks code is
  # variables:
  databricks_host       = var.databricks_host
  databricks_token      = var.databricks_token
  s3_bucket_name        = module.s3_bucket.s3_bucket_name
  databricks_user_email = var.databricks_user_email
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  tags                  = var.tags
}
