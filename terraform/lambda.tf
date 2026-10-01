resource "aws_lambda_function" "carevoice" {
  function_name = var.lambda_function_name

  filename = "${path.module}/../carevoice_lambda_final.zip"

  role    = data.aws_lambda_function.carevoice.role
  handler = "handler.lambda_handler"
  runtime = "python3.14"

  architectures = ["arm64"]

  memory_size = 128
  timeout     = 3

  publish = false

  environment {
    variables = {
      CAREVOICE_APPOINTMENTS_TABLE = var.dynamodb_table_name
    }
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      filename,
      source_code_hash
    ]
  }
}
