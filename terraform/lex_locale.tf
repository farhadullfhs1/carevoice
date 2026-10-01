resource "aws_lexv2models_bot_locale" "carevoice" {
  bot_id      = aws_lexv2models_bot.carevoice.id
  bot_version = "DRAFT"
  locale_id   = "en_US"

  description = "English language configuration for CareVoice."

  n_lu_intent_confidence_threshold = 0.8

  voice_settings {
    engine   = "standard"
    voice_id = "Matthew"
  }
}
