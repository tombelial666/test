---
name: sub-account-sftp-to-s3-tests
description: Execute sub-account ingestion regression for SFTP to S3 pipeline using controlled payloads, Lambda invocation, CloudWatch log checks, and SQL validation for TC-02..TC-07 scenarios.

---

# Sub Account Sftp To S3 Tests

## Trigger scenarios
- sub-account ingestion validation is requested
- IntegrationSftpToS3TEST troubleshooting is required
- E/F account behavior and eDocs propagation must be verified

## Run command
- `.\\run-optimized-tc.ps1 -FunctionName \"IntegrationSftpToS3TEST\" -Region \"us-east-1\" -PayloadFile \".\\json.json\"`
- `aws lambda invoke --function-name IntegrationSftpToS3TEST --region us-east-1 --cli-binary-format raw-in-base64-out --payload file://json.json lambda-response.json`

## Required inputs
- `AWS_PROFILE`
- `DB_SERVER`
- `DB_USER`
- `DB_PASSWORD`
- `TRADER_DB`
- `AMS_DB`

## Safety
- no_secrets_in_repo: True
- pii_in_payloads_must_be_masked: True
- non_prod_only: True
- mutation_gating: {'flags': ['SKIP_INVOKE', 'SKIP_SQL', 'SKIP_LOGS']}

## Evidence
- `aiqa/evidence/qa-suite-inventory/2026-04-25-agents-skills-v1/qa-suite-inventory.md`
- `aiqa/tasks/sub-account/README.md`
- `aiqa/tasks/sub-account/run-optimized-tc.ps1`
- `aiqa/tasks/sub-account/probe-sftp-paths.ps1`
