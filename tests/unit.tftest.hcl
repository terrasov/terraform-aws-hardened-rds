mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  identifier             = "terrasov-test"
  kms_key_arn            = "arn:aws:kms:eu-central-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  subnet_ids             = ["subnet-aaa11111", "subnet-bbb22222"]
  vpc_security_group_ids = ["sg-12345678"]
}

run "hardened_defaults" {
  command = plan

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Storage encryption must always be on."
  }

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "Instance must never be publicly accessible."
  }

  assert {
    condition     = aws_db_instance.this.manage_master_user_password == true
    error_message = "Master password must be RDS-managed in Secrets Manager."
  }

  assert {
    condition     = aws_db_instance.this.iam_database_authentication_enabled == true
    error_message = "IAM database authentication must be enabled."
  }

  assert {
    condition     = aws_db_instance.this.backup_retention_period == 14 && aws_db_instance.this.deletion_protection == true && aws_db_instance.this.multi_az == true
    error_message = "Backups, deletion protection and Multi-AZ must default to production posture."
  }

  assert {
    condition     = aws_db_instance.this.tags["data_residency"] == "eu"
    error_message = "data_residency tag must be pinned to eu."
  }

  assert {
    condition     = aws_db_instance.this.monitoring_interval == 60 && length(aws_iam_role.monitoring) == 1
    error_message = "Enhanced Monitoring must default to 60s with an in-module role."
  }
}

run "tls_forced_in_parameter_group" {
  command = plan

  assert {
    condition     = length([for p in aws_db_parameter_group.this.parameter : p if p.name == "rds.force_ssl" && p.value == "1"]) == 1
    error_message = "Parameter group must set rds.force_ssl = 1."
  }
}

run "rejects_public_classification" {
  command = plan

  variables {
    data_classification = "public"
  }

  expect_failures = [var.data_classification]
}

run "rejects_low_backup_retention" {
  command = plan

  variables {
    backup_retention_days = 3
  }

  expect_failures = [var.backup_retention_days]
}

run "rejects_single_subnet" {
  command = plan

  variables {
    subnet_ids = ["subnet-aaa11111"]
  }

  expect_failures = [var.subnet_ids]
}
