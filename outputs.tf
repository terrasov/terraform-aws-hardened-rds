output "instance_arn" {
  description = "DB instance ARN."
  value       = aws_db_instance.this.arn
}

output "instance_id" {
  description = "DB instance identifier."
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "Connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the managed master password."
  value       = one(aws_db_instance.this.master_user_secret[*].secret_arn)
}
