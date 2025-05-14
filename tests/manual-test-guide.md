# 🧪 Manual Test Plan Using Your Sample Files

This method lets you test the full bronze → silver → gold pipeline using real data, step by step.

---

### 🔹 Step 1: Run the pipeline with **no data**

1. Make sure the S3 bucket is empty (no `.jsonl` files).
2. Trigger the full pipeline (e.g. run the Databricks job).
3. After it completes, query the final table:

```sql
SELECT * FROM silver.transactions
```

✅ If this works without errors, your pipeline handles **empty input** correctly.

---

### 🔹 Step 2: Upload a few test files

1. Use the `upload_transactions.ps1` script to upload **1 or 2 files** from the `sample_data/` folder to S3.
2. Rerun the full pipeline (or trigger only the bronze-to-silver steps).
3. Query the tables:

```sql
SELECT * FROM hive_metastore.silver.stripe_transactions;
SELECT * FROM hive_metastore.silver.paypal_transactions;
SELECT * FROM hive_metastore.silver.transactions;
```

✅ Check that:

* The new data appears in silver layer.
* Row counts match the number of uploaded records.
* Schema is correct and clean.

---

### 🔹 Step 3: Repeat with more files

Gradually increase input files and re-run the pipeline:

* Upload 3–4 files

At each step, verify:

* No duplicate rows
* Correct number of records
* All important fields are filled
* Silver table includes data from both sources
