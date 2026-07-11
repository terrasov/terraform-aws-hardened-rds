# terraform-aws-hardened-rds

Opinionated hardened PostgreSQL RDS instance. The security posture is **not configurable**:

- Storage encrypted with a **customer-managed key** (required variable, no fallback)
- Master password generated and rotated by RDS in Secrets Manager, CMK-encrypted — **there
  is no password variable**, nothing lands in state or CI logs
- IAM database authentication enabled
- `rds.force_ssl = 1` — plaintext connections rejected by the engine
- Never publicly accessible
- Automated backups >= 7 days, final snapshot always taken, backups survive deletion
- Multi-AZ + deletion protection by default (opt out for sandboxes)
- Enhanced Monitoring with an in-module role (60s default)

## Usage

```hcl
module "db" {
  source  = "terrasov/hardened-rds/aws"
  version = "~> 1.0"

  identifier             = "acme-prod"
  kms_key_arn            = aws_kms_key.data.arn
  subnet_ids             = module.network.data_subnet_ids
  vpc_security_group_ids = [aws_security_group.db.id]
}
```

Tests: native `terraform test` with a mocked provider.

## Compliance mapping (the paid layer)

This module is the generic core of [TerraSov](https://terrasov.dev)'s `rds-secure`. The
subscription adds per-resource **ISO 27001 / BSI C5 / ENS / GDPR** clause annotations
verified against official texts, custom Checkov policies with a PR-blocking CI gate,
auditor evidence guides, and 7 further modules (EU region-lock SCPs, immutable audit
trail, IAM/network baselines).

## License

Apache-2.0
