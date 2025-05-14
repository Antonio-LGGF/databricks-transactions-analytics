# Create an S3 bucket and folders for the Databricks transactions analytics project
# This module creates an S3 bucket and the following folders:

# Create bucket 
# ps: the bucket name is passed as a variable, and the tags are also passed as a variable.
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}


# Create "bronze/" folder
resource "aws_s3_object" "bronze_folder" {
  bucket = aws_s3_bucket.this.bucket
  key    = "bronze/"
}

####################################################################################
# Create "silver/" folder and 3 subfolders:
# Create "silver/" folder
resource "aws_s3_object" "silver_folder" {
  bucket = aws_s3_bucket.this.bucket
  key    = "silver/"
}

# # Create subfolder "silver/transactions" folder
# resource "aws_s3_object" "silver_transactions_folder" {
#   bucket = aws_s3_bucket.this.bucket
#   key    = "silver/transactions"
# }

# # Create subfolder "silver/stripe_staging_transactions" folder
# resource "aws_s3_object" "stripe_staging_transactions_folder" {
#   bucket = aws_s3_bucket.this.bucket
#   key    = "silver/stripe_staging_transactions"
# }

# # Create subfolder "silver/paypal_staging_transactions" folder
# resource "aws_s3_object" "paypal_staging_transactions_folder" {
#   bucket = aws_s3_bucket.this.bucket
#   key    = "silver/paypal_staging_transactions"
# }

####################################################################################
# Create "gold/" folder
resource "aws_s3_object" "gold_folder" {
  bucket = aws_s3_bucket.this.bucket
  key    = "gold/"
}
