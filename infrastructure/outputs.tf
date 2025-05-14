output "s3_bucket_name" {
  description = "The name of the created S3 bucket"
  value       = module.s3_bucket.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "cluster_id" {
  description = "ID of the Databricks cluster"
  value       = module.databricks.cluster_id
}

output "databricks_job_id" {
  description = "ID of the Lakehouse Data Pipeline job"
  value       = module.databricks.databricks_job_id
}