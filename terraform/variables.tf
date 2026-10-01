variable "aws_region" {
  description = "AWS region for CareVoice"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "lambda_function_name" {
  description = "Existing CareVoice Lambda function"
  type        = string
  default     = "CareVoiceLexHandler"
}

variable "dynamodb_table_name" {
  description = "Existing CareVoice appointment table"
  type        = string
  default     = "CareVoiceAppointments"
}

variable "lex_bot_name" {
  description = "CareVoice Lex V2 bot"
  type        = string
  default     = "CareVoice"
}

variable "lex_bot_id" {
  description = "Existing CareVoice Lex V2 bot ID"
  type        = string
  default     = "GI63FYGIDU"
}

variable "lex_locale_id" {
  description = "CareVoice Lex locale"
  type        = string
  default     = "en_US"
}

variable "lex_alias_id" {
  description = "Existing CareVoice Lex test alias ID"
  type        = string
  default     = "TSTALIASID"
}
