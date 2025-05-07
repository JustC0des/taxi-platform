output "iam_role_put_order_name" {
  description = "The name of the IAM role for the put_order Lambda function."
  value       = aws_iam_role.lambda_put_order.name
}

output "iam_role_put_order_arn" {
  description = "The ARN of the IAM role for the put_order Lambda function."
  value       = aws_iam_role.lambda_put_order.arn
}


