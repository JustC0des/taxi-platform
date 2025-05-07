resource "aws_kms_key" "default" {
  for_each                 = toset(var.kms_services)
  description              = "KMS key for ${each.key} service"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "${each.value}.amazonaws.com",
          ]
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ],
        Resource = "arn:aws:kms:${var.region}:${var.account_id}:key/*${each.value}*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/specific-kms-admin-role"
          #Todo : replace with the actual role ARN
        },
        Action = [
          "kms:DescribeKey",
          "kms:EnableKey",
          "kms:DisableKey",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:ListAliases"
        ],
        Resource = "arn:aws:kms:${var.region}:${var.account_id}:key/*${each.value}*"
      },
    ]
  })
}