# Creates a minimal Databricks cluster for development
resource "databricks_cluster" "my_cluster" {
  spark_version           = "13.3.x-scala2.12"
  node_type_id            = "r5.large"
  autotermination_minutes = 30
  num_workers             = 1

  aws_attributes {
    availability     = "ON_DEMAND"
    ebs_volume_count = 1
    ebs_volume_size  = 100
  }

  data_security_mode = "SINGLE_USER"
  single_user_name   = var.databricks_user_email
}