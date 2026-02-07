output "oltp_endpoint" {
  value = aws_db_instance.oltp.address
}

output "replica_endpoint" {
  value = aws_db_instance.replica.address
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}

output "s3_bucket" {
  value = aws_s3_bucket.analytics.bucket
}

output "glue_database" {
  value = aws_glue_catalog_database.db.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.wg.name
}
