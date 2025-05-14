# upload_transactions.ps1

# To run:
# 1. Open PowerShell.
# 2. cd to the script folder.
# 3. To execute just: .\infrastructure\s3\sample_data\upload_transactions.ps1


aws s3 cp .\infrastructure\s3\sample_data\paypal_transactions_2025-05-01_001.jsonl s3://dev-databricks-transactions-analytics/bronze/paypal/2025/05/01/
aws s3 cp .\infrastructure\s3\sample_data\stripe_transactions_2025-05-01_001.jsonl s3://dev-databricks-transactions-analytics/bronze/stripe/2025/05/01/

# aws s3 cp .\infrastructure\s3\sample_data\paypal_transactions_2025-05-01_002.jsonl s3://dev-databricks-transactions-analytics/bronze/paypal/2025/05/01/
# aws s3 cp .\infrastructure\s3\sample_data\stripe_transactions_2025-05-01_002.jsonl s3://dev-databricks-transactions-analytics/bronze/stripe/2025/05/01/

# aws s3 cp .\infrastructure\s3\sample_data\paypal_transactions_2025-05-02_001.jsonl s3://dev-databricks-transactions-analytics/bronze/paypal/2025/05/02/
# aws s3 cp .\infrastructure\s3\sample_data\stripe_transactions_2025-05-02_001.jsonl s3://dev-databricks-transactions-analytics/bronze/stripe/2025/05/02/

# aws s3 cp .\infrastructure\s3\sample_data\paypal_transactions_2025-05-02_002.jsonl s3://dev-databricks-transactions-analytics/bronze/paypal/2025/05/02/
# aws s3 cp .\infrastructure\s3\sample_data\stripe_transactions_2025-05-02_002.jsonl s3://dev-databricks-transactions-analytics/bronze/stripe/2025/05/02/