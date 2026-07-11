variable "identifier" {
  description = "DB instance identifier."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.identifier))
    error_message = "identifier must start with a letter and contain only lowercase letters, digits and hyphens."
  }
}

variable "kms_key_arn" {
  description = "CMK for storage, Performance Insights and the managed master-user secret."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:\\d{12}:key/", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS key ARN."
  }
}

variable "engine_version" {
  description = "PostgreSQL engine version (the module is PostgreSQL-only in v1)."
  type        = string
  default     = "16.8"
}

variable "parameter_group_family" {
  description = "Parameter group family matching engine_version (e.g. postgres16)."
  type        = string
  default     = "postgres16"
}

variable "instance_class" {
  description = "Instance class."
  type        = string
  default     = "db.t4g.small"
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling in GiB (0 disables autoscaling)."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
  default     = "app"
}

variable "master_username" {
  description = "Master username. The password is generated and stored in Secrets Manager (never in state or variables)."
  type        = string
  default     = "dbadmin"
}

variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (>= 2 AZs)."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnet IDs in different AZs."
  }
}

variable "vpc_security_group_ids" {
  description = "Security groups attached to the instance."
  type        = list(string)

  validation {
    condition     = length(var.vpc_security_group_ids) > 0
    error_message = "Provide at least one security group."
  }
}

variable "backup_retention_days" {
  description = "Automated backup retention."
  type        = number
  default     = 14

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "multi_az" {
  description = "Standby replica in a second AZ. Disable only in sandboxes."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Protect the instance from deletion. Disable only in sandboxes."
  type        = bool
  default     = true
}

variable "enable_performance_insights" {
  description = "Performance Insights, encrypted with the CMK. Off by default (cost)."
  type        = bool
  default     = false
}

variable "monitoring_interval_seconds" {
  description = "Enhanced Monitoring granularity in seconds (0 disables it; the gate flags 0 in production)."
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval_seconds)
    error_message = "monitoring_interval_seconds must be one of 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "tags" {
  description = "Additional tags merged onto all resources. data_classification and data_residency are always set by the module."
  type        = map(string)
  default     = {}
}

variable "data_classification" {
  description = "Classification of the data stored in this database."
  type        = string
  default     = "confidential"

  validation {
    condition     = contains(["internal", "confidential", "restricted"], var.data_classification)
    error_message = "data_classification must be internal, confidential or restricted (a relational database is never 'public')."
  }
}
