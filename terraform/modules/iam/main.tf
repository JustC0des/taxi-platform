resource "aws_iam_role" "lambda_put_order" {
  name        = "iam_role.lambda_put_order_role.prd"
  description = "IAM role for Lambda function to put orders in DynamoDB"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        },
      ]
    }
  )
}

resource "aws_iam_policy" "lambda_put_order" {
  name        = "iam_policy.lambda_put_order.prd"
  description = "Policy for Lambda function to put orders in DynamoDB"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:PutItem"
          ],
          "Resource" : [
            var.dynamodb_table_orders_name
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sqs:SendMessage"
          ],
          "Resource" : [
            "arn:aws:sqs:*:*:*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_put_order" {
  role       = aws_iam_role.lambda_put_order.name
  policy_arn = aws_iam_policy.lambda_put_order.arn
}



resource "aws_iam_role" "lambda_json_to_pdf" {
  name        = "iam_role.lambda_json_to_pdf_role.prd"
  description = "IAM role for Lambda function to convert JSON data to PDF receipts"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "lambda_json_to_pdf" {
  name        = "iam_policy.lambda_json_to_pdf.prd"
  description = "Policy for Lambda function to convert JSON data to PDF receipts"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject"
          ],
          "Resource" : [
            "${var.taxi_drives_bucket_arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sqs:SendMessage"
          ],
          "Resource" : [
            "arn:aws:sqs:*:*:*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_json_to_pdf" {
  role       = aws_iam_role.lambda_put_order.name
  policy_arn = aws_iam_policy.lambda_put_order.arn
}