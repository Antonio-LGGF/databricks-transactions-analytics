## 🧭 Pipeline Overview (Silver Layer Focus)

This pipeline ingests Stripe and PayPal data into staging tables, then merges those into a unified transactions table — all within the **silver layer**.

---

### 🔹 Step 1 — Ingest to Staging Tables

| Notebook                                     | Action                                                                    |
| -------------------------------------------- | ------------------------------------------------------------------------- |
| `_01_1_1_ingest_stripe_bronze_to_staging.py` | Ingests new Stripe `.jsonl` files from S3 into the `staging_stripe` table |
| `_01_2_1_ingest_paypal_bronze_to_staging.py` | Ingests new PayPal `.jsonl` files from S3 into the `staging_paypal` table |

📍 Both staging tables are located in the **silver layer**.

---

### 🔹 Step 2 — Merge into Silver Transactions Table

| Notebook                                    | Action                                                                                   |
| ------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `_01_1_2_merge_stripe_staging_to_silver.py` | Merges data from `staging_stripe` into the main `transactions` table in the silver layer |
| `_01_2_2_merge_paypal_staging_to_silver.py` | Merges data from `staging_paypal` into the same `transactions` table in the silver layer |

✅ The `transactions` table acts as a unified, cleaned, and deduplicated dataset for downstream use.

---

Absolutely — here’s a clearer and well-structured explanation of your pipeline logic:

---

### 🧭 Pipeline Overview (Silver Layer Focus)

This pipeline ingests Stripe and PayPal data into staging tables, then merges those into a unified transactions table — all within the **silver layer**.

---

### 🔹 Step 1 — Ingest to Staging Tables

| Notebook                                     | Action                                                                    |
| -------------------------------------------- | ------------------------------------------------------------------------- |
| `_01_1_1_ingest_stripe_bronze_to_staging.py` | Ingests new Stripe `.jsonl` files from S3 into the `staging_stripe` table |
| `_01_2_1_ingest_paypal_bronze_to_staging.py` | Ingests new PayPal `.jsonl` files from S3 into the `staging_paypal` table |

📍 Both staging tables are located in the **silver layer**.

---

### 🔹 Step 2 — Merge into Silver Transactions Table

| Notebook                                    | Action                                                                                   |
| ------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `_01_1_2_merge_stripe_staging_to_silver.py` | Merges data from `staging_stripe` into the main `transactions` table in the silver layer |
| `_01_2_2_merge_paypal_staging_to_silver.py` | Merges data from `staging_paypal` into the same `transactions` table                     |

✅ The `transactions` table acts as a unified, cleaned, and deduplicated dataset for downstream use.

---

### 📊 Pipeline Flow Diagram 
```
        [New Stripe JSONL files]                     [New PayPal JSONL files]
                 |                                        |
                 v                                        v
_01_1_1_ingest_stripe_bronze_to_staging.py       _01_2_1_ingest_paypal_bronze_to_staging.py
                 |                                        |
                 v                                        v
  [silver.staging_stripe table]                     [silver.staging_paypalm table]
                 |                                        |
                 v                                        v
_01_1_2_merge_stripe_staging_to_silver.py       _01_2_2_merge_paypal_staging_to_silver.py
                                \                    /
                                 \                  /
                                  v                v
                             [silver.transactions table]
```



