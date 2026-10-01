resource "aws_lambda_permission" "allow_lex" {
  statement_id = "lex-lambda-invokeFunction-GI63FYGIDU-TSTALIASID"

  action = "lambda:invokeFunction"

  function_name = aws_lambda_function.carevoice.function_name

  principal = "lexv2.amazonaws.com"

  source_account = data.aws_caller_identity.current.account_id

  source_arn = "arn:aws:lex:${var.aws_region}:${data.aws_caller_identity.current.account_id}:bot-alias/${var.lex_bot_id}/${var.lex_alias_id}"
}
