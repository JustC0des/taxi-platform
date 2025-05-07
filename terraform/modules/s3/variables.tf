variable "account_id" {
  description = "The AWS account ID where the S3 bucket will be created."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "The account ID must be a 12-digit number."
  }
}

variable "s3_kms_key_arn" {
  description = "KMS key ARN for S3 service"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z]{2}-[a-z]+-[1-9]{1}:[0-9]{12}:key/[a-zA-Z0-9+=,.@_-]+$", var.s3_kms_key_arn))
    error_message = "The KMS key ARN must be in the format 'arn:aws:kms:<region>:<account_id>:key/<key_id>'."
  }
}