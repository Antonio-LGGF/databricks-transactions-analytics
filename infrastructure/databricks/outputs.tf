output "databricks_job_id" {
  description = "ID of the Lakehouse Data Pipeline job"
  value       = databricks_job.data_pipeline.id
}

output "cluster_id" {
  description = "ID of the created Databricks cluster"
  value       = databricks_cluster.my_cluster.id
}
