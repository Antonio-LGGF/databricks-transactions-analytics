resource "databricks_job" "data_pipeline" {
  name = "Lakehouse Data Pipeline" # Name of your Databricks job

  max_concurrent_runs = 1

  email_notifications {
    on_failure = [var.databricks_user_email]
  }

  schedule {
    # Run the job every 4 hours (at 00:00, 04:00, 08:00, etc.)
    quartz_cron_expression = "0 0 0/4 ? * * *"

    # Timezone for the schedule
    timezone_id = "UTC"

    # Start the job in active mode (not paused)
    pause_status = "UNPAUSED"
  }

  task {
    task_key            = "_01_1_1_ingest_stripe_bronze_to_staging" # Unique key for this task
    existing_cluster_id = databricks_cluster.my_cluster.id          # Use the same cluster
    
    timeout_seconds   = 3600
    max_retries       = 1
    retry_on_timeout  = true

    notebook_task {
      notebook_path = databricks_notebook._01_1_1_ingest_stripe_bronze_to_staging.path # Path to the notebook
      source        = "WORKSPACE"
    }
  }

  task {
    task_key            = "_01_2_1_ingest_paypal_bronze_to_staging" # Unique key for this task
    existing_cluster_id = databricks_cluster.my_cluster.id          # Use the same cluster
    
    timeout_seconds   = 3600
    max_retries       = 1
    retry_on_timeout  = true

    notebook_task {
      notebook_path = databricks_notebook._01_2_1_ingest_paypal_bronze_to_staging.path # Path to the notebook
      source        = "WORKSPACE"
    }
  }

  task {
    task_key = "_01_1_2_merge_stripe_staging_to_silver" # Unique key for this task
    depends_on { task_key = "_01_1_1_ingest_stripe_bronze_to_staging" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster
    
    timeout_seconds   = 3600
    max_retries       = 1
    retry_on_timeout  = true

    notebook_task {
      notebook_path = databricks_notebook._01_1_2_merge_stripe_staging_to_silver.path # Path to the notebook
      source        = "WORKSPACE"
    }
  }

  task {
    task_key = "_01_2_2_merge_paypal_staging_to_silver" # Unique key for this task
    depends_on { task_key = "_01_2_1_ingest_paypal_bronze_to_staging" }
    depends_on { task_key = "_01_1_2_merge_stripe_staging_to_silver" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster
    
    timeout_seconds   = 3600
    max_retries       = 1
    retry_on_timeout  = true

    notebook_task {
      notebook_path = databricks_notebook._01_2_2_merge_paypal_staging_to_silver.path # Path to the notebook
      source        = "WORKSPACE"
    }
  }

  task {
    task_key = "_02_silver_to_gold"                                    # Unique key for this task
    depends_on { task_key = "_01_1_2_merge_stripe_staging_to_silver" } # This task depends on 'bronze_to_silver_stripe'
    depends_on { task_key = "_01_2_2_merge_paypal_staging_to_silver" }
    existing_cluster_id = databricks_cluster.my_cluster.id # Use the same cluster
    
    timeout_seconds   = 3600
    max_retries       = 1
    retry_on_timeout  = true

    notebook_task {
      notebook_path = databricks_notebook._02_silver_to_gold.path # Path to the notebook
      source        = "WORKSPACE"
    }
  }
}