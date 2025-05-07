resource "aws_s3_bucket" "taxi_drives" {
  bucket = "taxi-drives"
  lifecycle {
    prevent_destroy = true
  }


  tags = {
    Name        = "taxi-drives"
    Environment = "prd"
  }
}

resource "aws_s3_bucket_public_access_block" "taxi_drives" {
  bucket                  = aws_s3_bucket.taxi_drives.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "taxi_drives" {
  bucket = aws_s3_bucket.taxi_drives.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.s3_kms_key_arn
    }
  }
}

resource "aws_s3_bucket_policy" "taxi_drives" {
  bucket = aws_s3_bucket.taxi_drives.id
  policy = data.aws_iam_policy_document.taxi_drives.json
}

data "aws_iam_policy_document" "taxi_drives" {
  statement {
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.taxi_drives.arn,
      "${aws_s3_bucket.taxi_drives.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
    effect = "Allow"
  }
}

locals {
  s3_bucket_objects = [
    "raw_data",
    "enriched_data",
    "receipts"
  ]
}

# Create folders in the S3 bucket
resource "aws_s3_object" "folders" {
  for_each = toset(local.s3_bucket_objects)
  bucket   = aws_s3_bucket.taxi_drives.bucket
  key      = each.value
}
