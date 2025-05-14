# Testing Strategy

This folder contains testing information for the Databricks Transactions Analytics pipeline.

## Contents

- `manual-test-guide.md`: Step-by-step instructions to manually test the full pipeline using sample `.jsonl` files.
- (future) `unit-tests/`: Optional folder for automated tests (e.g. with Pytest or Great Expectations)

## Current Testing Method

We use manual validation by uploading different sets of `.jsonl` files to S3, running the pipeline, and verifying the results in each table.

This allows you to check that the bronze → silver → gold flow is working end-to-end.

For full instructions, see [`manual-test-guide.md`](./manual-test-guide.md).
