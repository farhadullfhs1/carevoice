data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_lambda_function" "carevoice" {
  function_name = var.lambda_function_name
}

data "aws_iam_role" "carevoice_lambda" {
  name = element(
    reverse(
      split(
        "/",
        data.aws_lambda_function.carevoice.role
      )
    ),
    0
  )
}

data "aws_cloudwatch_log_group" "carevoice" {
  name = "/aws/lambda/${var.lambda_function_name}"
}
