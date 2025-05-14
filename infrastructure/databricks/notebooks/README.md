# Databricks Notebooks

These notebooks process Stripe and PayPal transactions using the Medallion Architecture.

## 💡 Execution Order

1. `01_1_1_ingest_stripe_bronze_to_staging.py`  
   Ingest Stripe data from S3 → staging table.

2. `01_1_2_merge_stripe_staging_to_silver.py`  
   Clean and merge Stripe staging data → silver.

3. `01_2_1_ingest_paypal_bronze_to_staging.py`  
   Ingest PayPal data from S3 → staging table.

4. `01_2_2_merge_paypal_staging_to_silver.py`  
   Clean and merge PayPal staging data → silver.

5. `02_silver_to_gold.py`  
   **[Empty for now]** Placeholder for future analytics logic using gold tables.

## 🧱 Architecture

- **Bronze**: Raw S3 data
- **Staging**: Temporary for validation
- **Silver**: Clean, structured
- **Gold**: Business-ready (not yet implemented)

## 📦 Output

- A cleaned silver table combining Stripe transactions and PayPal transactions : `silver.merged_transactions`
