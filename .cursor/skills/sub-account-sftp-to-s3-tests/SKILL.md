---
name: sub-account-sftp-to-s3-tests
description: Execute sub-account ingestion regression for SFTP to S3 pipeline using controlled payloads, Lambda invocation, CloudWatch log checks, and SQL validation for TC-02..TC-07 scenarios.

---

# Sub Account Sftp To S3 Tests

## When to use
- sub-account ingestion validation is requested
- IntegrationSftpToS3TEST troubleshooting is required
- E/F account behavior and eDocs propagation must be verified

## Out of scope
- storing real credentials or PII in repository artifacts
- production execution without explicit approval

## Run
- `(cwd: aiqa/tasks/sub-account) .\\run-optimized-tc.ps1 -FunctionName \"IntegrationSftpToS3TEST\" -Region \"us-east-1\" -PayloadFile \".\\json.json\"`
- `(cwd: aiqa/tasks/sub-account) aws lambda invoke --function-name IntegrationSftpToS3TEST --region us-east-1 --cli-binary-format raw-in-base64-out --payload file://json.json lambda-response.json`

## Inputs
**Required env**
- `AWS_PROFILE`
- `DB_SERVER`
- `DB_USER`
- `DB_PASSWORD`
- `TRADER_DB`
- `AMS_DB`

**Optional env**
- `FUNCTION_NAME`
- `REGION`
- `PAYLOAD_FILE`
- `ACCOUNT_E`
- `ACCOUNT_F`
- `BASE_ACCOUNT`
- `SKIP_INVOKE`
- `SKIP_LOGS`
- `SKIP_SQL`

**Optional CLI**
- n/a

## Endpoints
- `invoke aws:lambda:IntegrationSftpToS3TEST`
- `read aws:logs:/aws/lambda/IntegrationSftpToS3TEST`
- `query sql:etna_trader/et.ams`

## Safety
- no_secrets_in_repo: True
- pii_in_payloads_must_be_masked: True
- non_prod_only: True
- mutation_gating: {'flags': ['SKIP_INVOKE', 'SKIP_SQL', 'SKIP_LOGS']}

## Evidence basis
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `aiqa/tasks/sub-account/README.md`
- `aiqa/tasks/sub-account/run-optimized-tc.ps1`
- `aiqa/tasks/sub-account/probe-sftp-paths.ps1`

## Source spec
- `aiqa/skills-catalog/sub-account-sftp-to-s3-tests.yaml`
