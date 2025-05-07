resource "aws_lambda_function" "put_order" {
  function_name = "lambda_function_put_order_prd"
  handler       = "main.lambda_handler"
  runtime       = "python3.13"
  role          = var.iam_role_put_order_arn
  kms_key_arn   = var.lambda_kms_key_arn
  // file is fetched via the CI/CD pipeline from the application repository
  filename = "${path.module}/put_order.zip"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME   = var.dynamodb_table_orders_name
      DYNAMODB_VPC_ENDPOINT = "vpce-12345678"
    }
  }

  vpc_config {
    subnet_ids         = ["subnet-12345678", "subnet-87654321"]
    security_group_ids = ["sg-12345678"]
  }
}

resource "aws_lambda_function" "json_to_pdf" {
  function_name = "lambda_function_json_to_pdf_prd"
  handler       = "main.lambda_handler"
  runtime       = "python3.13"
  role          = var.iam_role_put_order_arn
  kms_key_arn   = var.lambda_kms_key_arn
  // file is fetched via the CI/CD pipeline from the application repository
  filename = "${path.module}/json_to_pdf.zip"
  environment {
    variables = {
      S3_DESTINATION  = var.receipts_s3_destination
      S3_VPC_ENDPOINT = "vpce-87654321"
    }
  }
  reserved_concurrent_executions = 100
  vpc_config {
    subnet_ids         = ["subnet-12345678", "subnet-87654321"]
    security_group_ids = ["sg-87654321"]
  }
}