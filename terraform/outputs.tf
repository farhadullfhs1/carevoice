output "aws_region" {
  value = var.aws_region
}

output "lambda_function_name" {
  value = data.aws_lambda_function.carevoice.function_name
}

output "lambda_arn" {
  value = data.aws_lambda_function.carevoice.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.appointments.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.appointments.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.carevoice.name
}
