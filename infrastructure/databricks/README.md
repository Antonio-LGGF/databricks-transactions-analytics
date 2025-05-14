# Databricks Module

This folder contains the Terraform module that provisions Databricks resources for the `Lakehouse Data Pipeline` project.

## 📦 Resources

- **Cluster**: Shared cluster for all job tasks
- **Jobs**: One Databricks job with multiple tasks (one notebook per task)
- **Notebooks**: Source code located in `notebooks/`
- **Secrets**: AWS credentials stored securely in a Databricks secret scope

## 📂 Notebooks (Pipeline Steps)

| Task Order | Notebook File                                             | Purpose                                |
|------------|-----------------------------------------------------------|----------------------------------------|
| 1          | `_01_1_1_ingest_stripe_bronze_to_staging.py`             | Ingest Stripe data into Bronze         |
| 2          | `_01_2_1_ingest_paypal_bronze_to_staging.py`             | Ingest PayPal data into Bronze         |
| 3          | `_01_1_2_merge_stripe_staging_to_silver.py`              | Clean Stripe data into Silver          |
| 4          | `_01_2_2_merge_paypal_staging_to_silver.py`              | Clean PayPal data into Silver          |
| 5          | `_02_silver_to_gold.py`                                   | Placeholder for future analytics logic using gold tables       |

## 🔐 Secrets

Secrets are stored in a Databricks scope called `s3-creds`.

They are accessed in notebooks using:

```python
dbutils.secrets.get(scope="s3-creds", key="aws-access-key-id")
dbutils.secrets.get(scope="s3-creds", key="aws-secret-access-key")
```

## 🚀 Execution
- This job is scheduled to run every 4 hours (cron-based).
- All tasks run in sequence, with retries and timeouts for safety.

## 📌 Notes
- The job is defined in jobs.tf
- The cluster is reusable
- Parameters are no longer passed from Terraform — secrets are used securely