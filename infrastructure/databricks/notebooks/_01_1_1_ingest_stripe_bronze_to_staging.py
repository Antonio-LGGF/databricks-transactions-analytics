# COMMAND ----------
# 0.0 
# Import required Spark functions and types
from pyspark.sql.functions import input_file_name, lit, col, upper, year, month, when
from pyspark.sql.types import StructType, StructField, StringType, LongType, DoubleType, TimestampType, IntegerType
from pyspark.sql.utils import AnalysisException
from delta.tables import DeltaTable

# COMMAND ----------
# 1.0 
# Set AWS credentials and S3 endpoint to read Stripe files
#
# Retrieve AWS credentials securely from Databricks secret scope
aws_access_key_id = dbutils.secrets.get(scope="s3-creds", key="aws-access-key-id")
aws_secret_access_key = dbutils.secrets.get(scope="s3-creds", key="aws-secret-access-key")
# Set AWS credentials in Spark to enable S3 access
spark._jsc.hadoopConfiguration().set("fs.s3a.access.key", aws_access_key_id)
spark._jsc.hadoopConfiguration().set("fs.s3a.secret.key", aws_secret_access_key)
spark._jsc.hadoopConfiguration().set("fs.s3a.endpoint", "s3.amazonaws.com")


# COMMAND ----------
# 2.0
# Define the schema of Stripe .jsonl files
stripe_schema = StructType([
    StructField("amount", LongType(), True),
    StructField("billing_details", StructType([
        StructField("address", StructType([
            StructField("city", StringType(), True),
            StructField("country", StringType(), True),
            StructField("line1", StringType(), True),
            StructField("postal_code", StringType(), True),
            StructField("state", StringType(), True),
        ]), True),
        StructField("email", StringType(), True),
        StructField("name", StringType(), True),
    ]), True),
    StructField("created", LongType(), True),
    StructField("currency", StringType(), True),
    StructField("description", StringType(), True),
    StructField("id", StringType(), True),
    StructField("metadata", StructType([
        StructField("order_id", StringType(), True)
    ]), True),
    StructField("object", StringType(), True),
    StructField("payment_method", StructType([
        StructField("card", StructType([
            StructField("brand", StringType(), True),
            StructField("exp_month", LongType(), True),
            StructField("exp_year", LongType(), True),
            StructField("last4", StringType(), True),
        ]), True),
        StructField("id", StringType(), True),
        StructField("type", StringType(), True),
    ]), True),
    StructField("receipt_email", StringType(), True),
    StructField("status", StringType(), True),
])

# COMMAND ----------
# 3.0 
# Extract data from new Stripe .jsonl files
# Read Stripe .jsonl files as a streaming DataFrame using Auto Loader
stripe_bronze_path = "s3://dev-databricks-transactions-analytics/bronze/stripe/"
stripe_df = (
    spark.readStream.format("cloudFiles")
    .option("cloudFiles.format", "json")
    .schema(stripe_schema)
    .load(stripe_bronze_path)
    .withColumn("source_file", input_file_name())  # Track input filename
    .withColumn("source", lit("stripe"))
)

# COMMAND ----------
# 4.0 
# Select and transform columns
#
# Select and rename key columns
stripe_df = stripe_df.select(
    col("id").alias("transaction_id"),
    col("amount"),
    col("currency"),
    col("status"),
    col("created"),
    col("source"),
    col("source_file")
)
# Convert "created" (UNIX timestamp) to "timestamp" column and drop original
stripe_df = stripe_df.withColumn("timestamp", col("created").cast("timestamp")).drop("created")
# Convert "amount" from cents to dollars and set negative/zero to null
stripe_df = stripe_df.withColumn(
    "amount", 
    when((col("amount") > 0), (col("amount") / 100).cast("double")).otherwise(None)
)
# Clean and standardize currency
valid_currencies = ["USD", "EUR", "GBP"]
stripe_df = stripe_df.withColumn(
    "currency",
    when(col("currency").isin(valid_currencies), upper(col("currency"))).otherwise("N/A")
)
# Clean status values
valid_statuses = ["succeeded", "failed", "pending"]
stripe_df = stripe_df.withColumn(
    "status",
    when(col("status").isin(valid_statuses), col("status")).otherwise("N/A")
)
# Remove rows with null timestamp
stripe_df = stripe_df.filter(col("timestamp").isNotNull())
# Extract year and month from the timestamp for partitioning or analysis
stripe_df = stripe_df \
    .withColumn("year", year("timestamp")) \
    .withColumn("month", month("timestamp"))

# COMMAND ----------
# 5.0 
# Order columns before apending
final_columns = [
    "transaction_id",
    "amount",
    "currency",
    "status",
    "timestamp",
    "source",
    "source_file",
    "year",
    "month"
]
stripe_df = stripe_df.select(*final_columns)

# COMMAND ----------
# 6.0 
# Copy stripe_df to silver.stripe_staging_transactions table
#
# Path to the silver.stripe_staging_transactions table
stripe_staging_transactions_path = "s3://dev-databricks-transactions-analytics/silver/stripe_staging_transactions/"
# Before copying, we create an empty delta table silver.staging_transactions table from an empty DataFrame
empty_schema = StructType([
    StructField("transaction_id", StringType()),
    StructField("amount", DoubleType()),
    StructField("currency", StringType()),
    StructField("status", StringType()),
    StructField("timestamp", TimestampType()),
    StructField("source", StringType()),
    StructField("source_file", StringType()),
    StructField("year", IntegerType()),
    StructField("month", IntegerType())
])
empty_df = spark.createDataFrame([], schema=empty_schema)
empty_df.write.format("delta").mode("overwrite").save(stripe_staging_transactions_path)
# Create the schema 'silver' if it doesn't exist 
# ps: workspace is the default catalog in Databricks.
spark.sql("CREATE SCHEMA IF NOT EXISTS hive_metastore.silver")
# Create the table 'stripe_staging_transactions' if it doesn't exist
# This is necessary to ensure the empty table (at stripe_staging_transactions_path) is registered in the metastore
spark.sql(f"""
CREATE TABLE IF NOT EXISTS hive_metastore.silver.stripe_staging_transactions
USING DELTA
LOCATION '{stripe_staging_transactions_path}'
""")
# Write the streaming DataFrame to the Delta table (Silver staging)
stripe_df.writeStream \
    .format("delta") \
    .outputMode("append") \
    .trigger(once=True) \
    .option("checkpointLocation", "s3://dev-databricks-transactions-analytics/checkpoints/stripe/") \
    .start(stripe_staging_transactions_path) \
    .awaitTermination()