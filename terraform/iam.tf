resource "aws_iam_role_policy" "carevoice_dynamodb" {
  name = "CareVoiceAppointmentsDynamoDBAccess"
  role = data.aws_iam_role.carevoice_lambda.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "CareVoiceAppointmentDynamoDBAccess"
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:GetItem"
        ]

        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}/index/*"
        ]
      }
    ]
  })
}
