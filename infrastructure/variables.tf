variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "databricks_host" {
  description = "Databricks workspace URL, like https://your-workspace.cloud.databricks.com"
  type        = string
}

variable "databricks_token" {
  description = "Databricks personal access token"
  type        = string
  sensitive   = true
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


