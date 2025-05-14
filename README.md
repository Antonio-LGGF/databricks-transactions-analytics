# Databricks Transactions Analytics

This project is a fully automated, production-grade **Lakehouse pipeline** using **Terraform**, **Databricks**, and **AWS S3**.

---

## 🚀 Features

- Infrastructure-as-Code with Terraform
- Modular architecture (S3 + Databricks)
- Secure secret handling via Databricks secret scopes
- Automated job orchestration using Databricks Jobs API
- Sample Stripe and PayPal data flows: Bronze → Silver → Gold

---

## 📦 Project Structure

```
infrastructure/
│
├── s3/             # S3 bucket + sample data
├── databricks/     # Databricks cluster, jobs, notebooks
├── main.tf         # Root module
├── variables.tf    # Shared input variables
├── outputs.tf      # Shared outputs
├── locals.tf       # Local values (e.g., naming)
```

---

## 🗂️ Modules

### 1. **S3 Module**
- Creates bucket and uploads `.jsonl` sample files
- Used by Databricks notebooks for ingestion

### 2. **Databricks Module**
- Creates secret scope, cluster, and a multi-task job
- Runs notebooks in dependency order every 4 hours

---

## 🔐 Secrets Handling

Secrets like AWS keys are:
- Stored in Databricks secret scope `s3-creds`
- Used securely inside notebooks (not passed via Terraform)

Access them with:
```python
dbutils.secrets.get(scope="s3-creds", key="aws-access-key-id")
```

---

## 🧪 Test Data

Sample transaction files for:
- `Stripe`: `stripe_transactions_*.jsonl`
- `PayPal`: `paypal_transactions_*.jsonl`

Upload to S3 using:
```powershell
./upload_transactions.ps1
```

---

## 📅 Schedule

The pipeline runs every **4 hours** using a cron expression.

---

## 📄 Prerequisites

- Terraform CLI
- AWS CLI (with configured credentials)
- Databricks CLI (set up with a token)

---

## 📌 Deployment

```bash
terraform init
terraform plan
terraform apply
```

---

## 👤 Author

- Antonio ([@Antonio-LGGF](https://github.com/Antonio-LGGF))
