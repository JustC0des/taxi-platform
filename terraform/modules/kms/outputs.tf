# output all kms key arns for this var.kms_services

output "lambda_kms_key_arn" {
  value       = aws_kms_key.default["lambda"].arn
  description = "KMS key ARN for Lambda service"
}

output "s3_kms_key_arn" {
  value       = aws_kms_key.default["s3"].arn
  description = "KMS key ARN for S3 service"
}

output "dynamodb_kms_key_arn" {
  value       = aws_kms_key.default["dynamodb"].arn
  description = "KMS key ARN for DynamoDB service"
}