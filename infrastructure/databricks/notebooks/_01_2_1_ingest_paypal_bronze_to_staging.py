# COMMAND ----------
# 0.0 
# Import required Spark functions and types
from pyspark.sql.functions import input_file_name, lit, col, to_timestamp, when, year, month, when, upper
from pyspark.sql.types import StructType, StructField, StringType, LongType, DoubleType, TimestampType, IntegerType, ArrayType
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
# Define the schema of paypal .jsonl files
paypal_schema = StructType([
    StructField("amount", StructType([
        StructField("currencyCode", StringType(), True),
        StructField("value", StringType(), True)
    ]), True),
    StructField("description", StringType(), True),
    StructField("items", ArrayType(StructType([
        StructField("name", StringType(), True),
        StructField("price", StructType([
            StructField("currencyCode", StringType(), True),
            StructField("value", StringType(), True)
        ]), True),
        StructField("quantity", LongType(), True)
    ]), True), True),
    StructField("merchant", StructType([
        StructField("merchantId", StringType(), True),
        StructField("name", StringType(), True)
    ]), True),
    StructField("payer", StructType([
        StructField("email", StringType(), True),
        StructField("payerId", StringType(), True)
    ]), True),
    StructField("status", StringType(), True),
    StructField("transactionId", StringType(), True),
    StructField("transactionTime", StringType(), True)
])

# COMMAND ----------
# 3.0 
# Extract data from new paypal .jsonl files
# Read paypal .jsonl files as a streaming DataFrame using Auto Loader
paypal_bronze_path = "s3://dev-databricks-transactions-analytics/bronze/paypal/"
paypal_df = (
    spark.readStream.format("cloudFiles")
    .option("cloudFiles.format", "json")
    .schema(paypal_schema)
    .load(paypal_bronze_path)
    .withColumn("source_file", input_file_name())  # Track input filename
    .withColumn("source", lit("paypal"))
)

# COMMAND ----------
# 4.0 
# Select and transform columns
#
# Select and rename key columns
paypal_df = paypal_df.select(
    col("transactionId").alias("transaction_id"),
    col("amount.value").alias("amount"),
    col("amount.currencyCode").alias("currency"),
    col("status"),
    col("transactionTime"),
    col("source"),
    col("source_file")
)
# Convert transactionTime to timestamp
paypal_df = paypal_df.withColumn(
    "timestamp", to_timestamp(col("transactionTime"))
).drop("transactionTime")
# Cast amount only if valid numeric format
paypal_df = paypal_df.withColumn(
    "amount",
    when(col("amount").rlike("^\\d+(\\.\\d+)?$"), col("amount").cast("double")).otherwise(None)
)
# Standardize currency to uppercase and keep only valid ones
valid_currencies = ["USD", "EUR", "GBP"]
paypal_df = paypal_df.withColumn(
    "currency",
    when(col("currency").isin(valid_currencies), upper(col("currency"))).otherwise("N/A")
)
# Clean status field
valid_statuses = ["COMPLETED", "PENDING", "FAILED"]
paypal_df = paypal_df.withColumn(
    "status",
    when(col("status").isin(valid_statuses), col("status")).otherwise("N/A")
)
# Drop rows with null timestamp
paypal_df = paypal_df.filter(col("timestamp").isNotNull())
# Extract year and month from timestamp
paypal_df = paypal_df \
    .withColumn("year", year("timestamp")) \
    .withColumn("month", month("timestamp"))
# COMMAND ----------
# 5.0 Order columns before apending
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
paypal_df = paypal_df.select(*final_columns)

# COMMAND ----------
# 6.0 
# Copy paypal_df to silver.paypal_staging_transactions table
#
# Path to the silver.paypal_staging_transactions table
paypal_staging_transactions_path = "s3://dev-databricks-transactions-analytics/silver/paypal_staging_transactions/"
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
empty_df.write.format("delta").mode("overwrite").save(paypal_staging_transactions_path)
# Create the schema 'silver' if it doesn't exist 
# ps: workspace is the default catalog in Databricks.
spark.sql("CREATE SCHEMA IF NOT EXISTS hive_metastore.silver")
# Create the table 'paypal_staging_transactions' if it doesn't exist
# This is necessary to ensure the empty table (at paypal_staging_transactions_path) is registered in the metastore
spark.sql(f"""
CREATE TABLE IF NOT EXISTS hive_metastore.silver.paypal_staging_transactions
USING DELTA
LOCATION '{paypal_staging_transactions_path}'
""")
# Write the streaming DataFrame to the Delta table (Silver staging)
paypal_df.writeStream \
    .format("delta") \
    .outputMode("append") \
    .trigger(once=True) \
    .option("checkpointLocation", "s3://dev-databricks-transactions-analytics/checkpoints/paypal/") \
    .start(paypal_staging_transactions_path) \
    .awaitTermination()
