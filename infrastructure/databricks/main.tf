# The code below creates a Databricks secret scope named "s3-creds"
# and stores two AWS credentials (access key ID and secret access key) inside it.
# These secrets can then be accessed securely in notebooks using dbutils.secrets.get.

resource "databricks_secret_scope" "my_scope" {
  name = "s3-creds"
}

resource "databricks_secret" "aws_access_key_id" {
  key          = "aws-access-key-id"
  string_value = var.aws_access_key_id
  scope        = databricks_secret_scope.my_scope.name
}

resource "databricks_secret" "aws_secret_access_key" {
  key          = "aws-secret-access-key"
  string_value = var.aws_secret_access_key
  scope        = databricks_secret_scope.my_scope.name
}

# The code below uploads local Python notebooks to the Databricks workspace.
# Each resource defines a notebook's path, language, and base64-encoded content.
# These notebooks are part of a data pipeline: ingest from Bronze, merge into Silver, and promote to Gold.

# stripe
resource "databricks_notebook" "_01_1_1_ingest_stripe_bronze_to_staging" {
  path           = "/Shared/_01_1_1_ingest_stripe_bronze_to_staging"
  language       = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/_01_1_1_ingest_stripe_bronze_to_staging.py"))
}

resource "databricks_notebook" "_01_1_2_merge_stripe_staging_to_silver" {
  path           = "/Shared/_01_1_2_merge_stripe_staging_to_silver"
  language       = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/_01_1_2_merge_stripe_staging_to_silver.py"))
}

# paypal
resource "databricks_notebook" "_01_2_1_ingest_paypal_bronze_to_staging" {
  path           = "/Shared/_01_1_1_ingest_paypal_bronze_to_staging"
  language       = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/_01_2_1_ingest_paypal_bronze_to_staging.py"))
}

resource "databricks_notebook" "_01_2_2_merge_paypal_staging_to_silver" {
  path           = "/Shared/_01_1_2_merge_paypal_staging_to_silver"
  language       = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/_01_2_2_merge_paypal_staging_to_silver.py"))
}

# Silver to Gold
resource "databricks_notebook" "_02_silver_to_gold" {
  path           = "/Shared/_02_silver_to_gold"
  language       = "PYTHON"
  content_base64 = base64encode(file("${path.module}/notebooks/_02_silver_to_gold.py"))
}