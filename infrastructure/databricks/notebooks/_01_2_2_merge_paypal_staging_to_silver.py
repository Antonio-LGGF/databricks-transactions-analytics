# COMMAND ----------
# 0.0 
# Import required Spark functions and types
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType, IntegerType
from pyspark.sql.utils import AnalysisException
from delta.tables import DeltaTable


# COMMAND ----------
# 1.0 
# First We need to create the table transactions if it doesn't exist yet.
# We append an empty data frame at the table in merged_transactions_path
# If there is no table yet in merged_transactions_path then the code will create an empty table 
# from the empty data frame
#
# path to the merged_transactions table
merged_transactions_path = "s3://dev-databricks-transactions-analytics/silver/merged_transactions/"
# We use try/except to handle the case where the table does not exist
try:
    # Check if the Delta table already exists at the specified path
    # returns a DeltaTable object (a pointer to the table) if the tables exists
    DeltaTable.forPath(spark, merged_transactions_path)
# If the table does not exist, it will raise a AnalysisException
except AnalysisException:
    # Create the schema of empty data frame
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
    # Create an empty DataFrame with the defined schema
    empty_df = spark.createDataFrame([], schema=empty_schema)
    # Write the empty DataFrame to Delta format
    empty_df.write \
        .format("delta") \
        .mode("overwrite") \
        .save(merged_transactions_path)
    # Register the Delta table in the Hive metastore
    spark.sql(f"""
    CREATE TABLE IF NOT EXISTS hive_metastore.silver.merged_transactions
    USING DELTA
    LOCATION '{merged_transactions_path}'
    """)

# COMMAND ----------
# 2.0 
# Merge insert/update silver.paypal_staging_transactions to silver.merged_transactions 
# We do a merge only if there are rows in the staging table
#
# Count rows in paypal_staging_transactions table. 
staging_count = spark.table("hive_metastore.silver.paypal_staging_transactions").count()
# If the count is 0, it means no new files were found.
if staging_count > 0:
    # As paypal_staging_transactions is not empty we can proceed with the merge
    # Merge the data from the staging table into the transactions table  (without creating duplicates)
    spark.sql("""
    MERGE INTO hive_metastore.silver.merged_transactions AS target
    USING hive_metastore.silver.paypal_staging_transactions AS source
    ON target.transaction_id = source.transaction_id
    WHEN MATCHED THEN UPDATE SET *
    WHEN NOT MATCHED THEN INSERT *
    """)
    # ps: Keeps the table definition, schema, table registered in the metastore
    spark.sql("TRUNCATE TABLE hive_metastore.silver.paypal_staging_transactions")
else:
    print("No new data in staging. Skipping MERGE.")