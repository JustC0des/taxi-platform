variable "account_id" {
  description = "The AWS account ID where the S3 bucket will be created."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "The account ID must be a 12-digit number."
  }
  default = "123456789012"
}

variable "region" {
  description = "The AWS region where the resources will be created."
  type        = string
  default     = "eu-central-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[1-9]{1}$", var.region))
    error_message = "The region must be in the format 'xx-xxxx-x'."
  }
}