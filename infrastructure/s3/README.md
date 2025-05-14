# S3 Module

This module provisions an Amazon S3 bucket for storing source data used in the Databricks Lakehouse pipeline.

## 📦 Resources

- **S3 Bucket**: Created using a unique name per environment
- **Objects**: Uploads sample Stripe and PayPal `.jsonl` data
- **IAM Integration**: Bucket is used as source for Databricks jobs

## 📁 Folder Structure

- `main.tf`: Creates the S3 bucket and uploads data
- `variables.tf`: Input variables like bucket name and tags
- `outputs.tf`: Outputs the bucket name
- `sample_data/`: Contains test `.jsonl` files and an upload script

## 🚀 Usage

This module is called from the root `main.tf` like so:

```hcl
module "s3_bucket" {
  source      = "./s3"
  bucket_name = local.s3_bucket_name
  tags        = var.tags
}
```

## 📂 Sample Data
Located in sample_data/:

- `paypal_transactions_*.jsonl`
- `stripe_transactions_*.jsonl`
- `upload_transactions.ps1` – script to send sample files to S3