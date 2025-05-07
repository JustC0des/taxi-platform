variable "dynamodb_kms_key_arn" {
  description = "KMS key ARN for Lambda service"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z]{2}-[a-z]+-[1-9]{1}:[0-9]{12}:key/[a-zA-Z0-9+=,.@_-]+$", var.dynamodb_kms_key_arn))
    error_message = "The KMS key ARN must be in the format 'arn:aws:kms:<region>:<account_id>:key/<key_id>'."
  }
}