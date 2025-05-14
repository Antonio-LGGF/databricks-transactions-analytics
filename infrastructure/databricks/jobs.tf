resource "databricks_job" "data_pipeline" {
  name = "Lakehouse Data Pipeline" # Name of your Databricks job

  # schedule {  # Uncomment this block if you want to schedule the job
  #   quartz_cron_expression = "0 */5 * * * ?" # Cron expression for scheduling (e.g., every 5 minutes)
  #   timezone_id           = "UTC"           # Timezone for the schedule
  #   pause_status          = "UNPAUSED"      # Job starts in an unpaused state
  # }

  task {
    task_key            = "_01_1_1_ingest_stripe_bronze_to_staging" # Unique key for this task
    existing_cluster_id = databricks_cluster.my_cluster.id          # Use the same cluster

    notebook_task {
      notebook_path = databricks_notebook._01_1_1_ingest_stripe_bronze_to_staging.path # Path to the notebook
      source        = "WORKSPACE"
      base_parameters = {
        aws_access_key_id     = var.aws_access_key_id,
        aws_secret_access_key = var.aws_secret_access_key
      }
    }
  }

  task {
    task_key            = "_01_2_1_ingest_paypal_bronze_to_staging" # Unique key for this task
    existing_cluster_id = databricks_cluster.my_cluster.id          # Use the same cluster

    notebook_task {
      notebook_path = databricks_notebook._01_2_1_ingest_paypal_bronze_to_staging.path # Path to the notebook
      source        = "WORKSPACE"
      base_parameters = {
        aws_access_key_id     = var.aws_access_key_id,
        aws_secret_access_key = var.aws_secret_access_key
      }
    }
  }

  task {
    task_key = "_01_1_2_merge_stripe_staging_to_silver" # Unique key for this task
    depends_on { task_key = "_01_1_1_ingest_stripe_bronze_to_staging" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster

    notebook_task {
      notebook_path = databricks_notebook._01_1_2_merge_stripe_staging_to_silver.path # Path to the notebook
      source        = "WORKSPACE"
      base_parameters = {
        aws_access_key_id     = var.aws_access_key_id,
        aws_secret_access_key = var.aws_secret_access_key
      }
    }
  }

  task {
    task_key = "_01_2_2_merge_paypal_staging_to_silver" # Unique key for this task
    depends_on { task_key = "_01_2_1_ingest_paypal_bronze_to_staging" }
    depends_on { task_key = "_01_1_2_merge_stripe_staging_to_silver" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster

    notebook_task {
      notebook_path = databricks_notebook._01_2_2_merge_paypal_staging_to_silver.path # Path to the notebook
      source        = "WORKSPACE"
      base_parameters = {
        aws_access_key_id     = var.aws_access_key_id,
        aws_secret_access_key = var.aws_secret_access_key
      }
    }
  }

  task {
    task_key = "_02_silver_to_gold"                                    # Unique key for this task
    depends_on { task_key = "_01_1_2_merge_stripe_staging_to_silver" } # This task depends on 'bronze_to_silver_stripe'
    depends_on { task_key = "_01_2_2_merge_paypal_staging_to_silver" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster

    notebook_task {
      notebook_path = databricks_notebook._02_silver_to_gold.path # Path to the notebook
      source        = "WORKSPACE"
      base_parameters = {
        aws_access_key_id     = var.aws_access_key_id,
        aws_secret_access_key = var.aws_secret_access_key
      }
    }
  }
}