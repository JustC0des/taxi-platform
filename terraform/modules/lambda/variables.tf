variable "receipts_s3_destination" {
  description = "The S3 destination for receipts data."
  type        = string
}

variable "iam_role_put_order_arn" {
  description = "The ARN of the IAM role for putting orders."
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@_-]+$", var.iam_role_put_order_arn))
    error_message = "The IAM role ARN must be in the format 'arn:aws:iam::<account_id>:role/<role_name>'."
  }
}

variable "dynamodb_table_orders_name" {
  description = "The name of the DynamoDB table for orders data."
  type        = string
}

variable "lambda_kms_key_arn" {
  description = "KMS key ARN for Lambda service"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z]{2}-[a-z]+-[1-9]{1}:[0-9]{12}:key/[a-zA-Z0-9+=,.@_-]+$", var.lambda_kms_key_arn))
    error_message = "The KMS key ARN must be in the format 'arn:aws:kms:<region>:<account_id>:key/<key_id>'."
  }
}