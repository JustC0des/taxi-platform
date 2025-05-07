output "dynamodb_table_orders_name" {
  value       = aws_dynamodb_table.orders.name
  description = "The name of the DynamoDB table for orders data."
}