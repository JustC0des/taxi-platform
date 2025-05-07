output "taxi_drives_bucket_name" {
  value       = aws_s3_bucket.taxi_drives.bucket
  description = "The name of the S3 bucket for taxi drives data."
}

output "taxi_drives_bucket_arn" {
  value       = aws_s3_bucket.taxi_drives.arn
  description = "The ARN of the S3 bucket for taxi drives data."
}

output "taxi_drives_raw_folder_key" {
  value       = aws_s3_object.folders["raw_data"].key
  description = "The key for the raw data folder in the S3 bucket."
}

output "taxi_drives_enriched_folder_key" {
  value       = aws_s3_object.folders["enriched_data"].key
  description = "The key for the enriched data folder in the S3 bucket."
}

output "taxi_drives_receipts_folder_key" {
  value       = aws_s3_object.folders["receipts"].key
  description = "The key for the receipts folder in the S3 bucket."
}