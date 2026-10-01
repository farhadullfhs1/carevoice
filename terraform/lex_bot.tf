resource "aws_lexv2models_bot" "carevoice" {
  name        = var.lex_bot_name
  description = "Voice-enabled healthcare assistance bot for CareVoice."

  idle_session_ttl_in_seconds = 300

  role_arn = "arn:aws:iam::589159459197:role/service-role/AmazonLexServiceRole-804A2QCY91Y"

  data_privacy {
    child_directed = false
  }

  tags = {
    Project     = "CareVoice"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
