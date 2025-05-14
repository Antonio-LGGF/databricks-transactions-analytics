variable "databricks_host" {
  description = "The URL of your Databricks workspace"
  type        = string
}

variable "databricks_token" {
  description = "The access token to authenticate with Databricks"
  type        = string
}

variable "s3_bucket_name" {
  description = "The S3 bucket name to read/write data"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}


variable "databricks_user_email" {
  description = "The email of the Databricks user"
  type        = string
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}