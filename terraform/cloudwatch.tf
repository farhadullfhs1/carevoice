resource "aws_cloudwatch_log_group" "carevoice" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 0

  lifecycle {
    prevent_destroy = true
  }
}
