variable "dynamodb_table_orders_name" {
  description = "The name of the DynamoDB table for orders data."
  type        = string
}

variable "taxi_drives_bucket_arn" {
  description = "The ARN of the S3 bucket for taxi drives data."
  type        = string
}