# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "FALLBCKINT:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "fallback" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Default intent when no other intent matches"
  locale_id               = "en_US"
  name                    = "FallbackIntent"
  parent_intent_signature = "AMAZON.FallbackIntent"
  region                  = "ap-northeast-2"
  initial_response_setting {
    code_hook {
      active                      = true
      enable_code_hook_invocation = true
      invocation_label            = null
      post_code_hook_specification {
        failure_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
        }
        success_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
        }
        timeout_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "InvokeDialogCodeHook"
      }
    }
  }
}

# __generated__ by Terraform from "SSJYQAPDZR:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "human_agent" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Handles requests to connect users with a human support representative."
  locale_id               = "en_US"
  name                    = "HumanAgent"
  parent_intent_signature = null
  region                  = "ap-northeast-2"
  fulfillment_code_hook {
    active  = true
    enabled = true
    post_fulfillment_status_specification {
      failure_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      failure_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I couldn't process your request right now. Please try again."
            }
          }
        }
      }
      success_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      success_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "Your request to speak with a support representative has been received."
            }
          }
        }
      }
      timeout_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      timeout_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "The support service is taking longer than expected. Please try again."
            }
          }
        }
      }
    }
  }
  initial_response_setting {
    initial_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "Sure, I'll help you connect with a support representative."
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "FulfillIntent"
      }
      intent {
        name = null
      }
    }
  }
  sample_utterance {
    utterance = "I want to talk to a human"
  }
  sample_utterance {
    utterance = "i want to talk to a agent"
  }
  sample_utterance {
    utterance = "Connect me to an agent"
  }
  sample_utterance {
    utterance = "I want to speak with someone"
  }
  sample_utterance {
    utterance = "Can I talk to a human"
  }
  sample_utterance {
    utterance = "Connect me with a representative"
  }
  sample_utterance {
    utterance = "I need to speak to an agent"
  }
  sample_utterance {
    utterance = "I want human assistance"
  }
  sample_utterance {
    utterance = "Let me talk to someone"
  }
  sample_utterance {
    utterance = "Transfer me to an agent"
  }
  sample_utterance {
    utterance = "I need to talk to a real person"
  }
  sample_utterance {
    utterance = "call a agent"
  }
}

# __generated__ by Terraform from "KHB1GXLETN:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "carevoice_help" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Handles general help requests from CareVoice users."
  locale_id               = "en_US"
  name                    = "CareVoiceHelp"
  parent_intent_signature = null
  region                  = "ap-northeast-2"
  fulfillment_code_hook {
    active  = true
    enabled = true
    post_fulfillment_status_specification {
      failure_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      failure_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "Please try again"
            }
          }
        }
      }
      success_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      success_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "We have successfully completed your request!"
            }
          }
        }
      }
      timeout_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
    }
  }
  initial_response_setting {
    code_hook {
      active                      = true
      enable_code_hook_invocation = true
      invocation_label            = null
      post_code_hook_specification {
        failure_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
        success_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "FulfillIntent"
          }
          intent {
            name = null
          }
        }
        timeout_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "InvokeDialogCodeHook"
      }
      intent {
        name = null
      }
    }
  }
  sample_utterance {
    utterance = "I need help"
  }
  sample_utterance {
    utterance = "I need some help"
  }
  sample_utterance {
    utterance = "Can you help me"
  }
  sample_utterance {
    utterance = "Help me please"
  }
  sample_utterance {
    utterance = "I need assistance"
  }
  sample_utterance {
    utterance = "I have a question"
  }
  sample_utterance {
    utterance = "Can you assist me"
  }
  sample_utterance {
    utterance = "I want some help"
  }
  sample_utterance {
    utterance = "Please help me"
  }
  sample_utterance {
    utterance = "What can you do"
  }
  sample_utterance {
    utterance = "Hello"
  }
  sample_utterance {
    utterance = "Hey"
  }
  sample_utterance {
    utterance = "Hii"
  }
}

# __generated__ by Terraform from "84IFCNJP8U:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "check_appointment" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Handles appointment status and appointment details requests."
  locale_id               = "en_US"
  name                    = "CheckAppointment"
  parent_intent_signature = null
  region                  = "ap-northeast-2"
  fulfillment_code_hook {
    active  = true
    enabled = true
    post_fulfillment_status_specification {
      failure_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      failure_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I couldn't retrieve your appointment details. Please try again."
            }
          }
        }
      }
      success_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      success_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I've received your appointment lookup request."
            }
          }
        }
      }
      timeout_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      timeout_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "The appointment lookup is taking longer than expected. Please try again."
            }
          }
        }
      }
    }
  }
  initial_response_setting {
    code_hook {
      active                      = true
      enable_code_hook_invocation = true
      invocation_label            = null
      post_code_hook_specification {
        failure_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
        success_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = "PatientName"
            suppress_next_message = null
            type                  = "ElicitSlot"
          }
          intent {
            name = null
          }
        }
        timeout_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
      }
    }
    initial_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "Sure, I can help you check your appointment details."
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "InvokeDialogCodeHook"
      }
      intent {
        name = null
      }
    }
  }
  sample_utterance {
    utterance = "I want to check my appointment"
  }
  sample_utterance {
    utterance = "Check my appointment"
  }
  sample_utterance {
    utterance = "What is the status of my appointment"
  }
  sample_utterance {
    utterance = "Show my appointment"
  }
  sample_utterance {
    utterance = "I want to see my appointment details"
  }
  sample_utterance {
    utterance = "Can you check my appointment"
  }
  sample_utterance {
    utterance = "When is my appointment"
  }
  sample_utterance {
    utterance = "Tell me about my appointment"
  }
  sample_utterance {
    utterance = "I want to know my appointment status"
  }
  sample_utterance {
    utterance = "Do I have an appointment"
  }
  slot_priority {
    priority = 1
    slot_id  = "SGKKVM86JN"
  }
  slot_priority {
    priority = 2
    slot_id  = "TDKZXFEUAH"
  }
}

# __generated__ by Terraform from "JZLYQHRGFX:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "hospital_information" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Provides general hospital information requested by CareVoice users."
  locale_id               = "en_US"
  name                    = "HospitalInformation"
  parent_intent_signature = null
  region                  = "ap-northeast-2"
  fulfillment_code_hook {
    active  = true
    enabled = true
    post_fulfillment_status_specification {
      failure_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      failure_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I couldn't retrieve that hospital information. Please try again."
            }
          }
        }
      }
      success_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      success_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I've received your hospital information request."
            }
          }
        }
      }
      timeout_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      timeout_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "The hospital information service is taking longer than expected. Please try again."
            }
          }
        }
      }
    }
  }
  initial_response_setting {
    code_hook {
      active                      = true
      enable_code_hook_invocation = true
      invocation_label            = null
      post_code_hook_specification {
        failure_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
        success_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = "InformationType"
            suppress_next_message = null
            type                  = "ElicitSlot"
          }
          intent {
            name = null
          }
        }
        timeout_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
      }
    }
    initial_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "Sure, I can provide the hospital information you need."
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "InvokeDialogCodeHook"
      }
      intent {
        name = null
      }
    }
  }
  sample_utterance {
    utterance = "I need hospital information"
  }
  sample_utterance {
    utterance = "I need the information about the clinic"
  }
  sample_utterance {
    utterance = "info about clinic"
  }
  sample_utterance {
    utterance = "info about hospital"
  }
  sample_utterance {
    utterance = "Tell me about the hospital"
  }
  sample_utterance {
    utterance = "What are the hospital timings"
  }
  sample_utterance {
    utterance = "What time does the hospital open"
  }
  sample_utterance {
    utterance = "What time does the hospital close"
  }
  sample_utterance {
    utterance = "Where is the hospital"
  }
  sample_utterance {
    utterance = "What services does the hospital provide"
  }
  sample_utterance {
    utterance = "Tell me about hospital services"
  }
  sample_utterance {
    utterance = "I want information about the hospital"
  }
  sample_utterance {
    utterance = "Can you give me hospital details"
  }
  sample_utterance {
    utterance = "Can you give me clinic details"
  }
  slot_priority {
    priority = 1
    slot_id  = "CPVCGIRLLK"
  }
}

# __generated__ by Terraform from "EGPWZAZYCW:GI63FYGIDU:DRAFT:en_US"
resource "aws_lexv2models_intent" "book_appointment" {
  bot_id                  = "GI63FYGIDU"
  bot_version             = "DRAFT"
  description             = "Handles appointment booking requests from CareVoice users."
  locale_id               = "en_US"
  name                    = "BookAppointment"
  parent_intent_signature = null
  region                  = "ap-northeast-2"
  confirmation_setting {
    active = true
    confirmation_next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "FulfillIntent"
      }
      intent {
        name = null
      }
    }
    confirmation_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "Great. I'll proceed with your appointment request."
          }
        }
      }
    }
    declination_next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "EndConversation"
      }
      intent {
        name = null
      }
    }
    declination_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "No problem. Let's start over with your appointment details."
          }
        }
      }
    }
    elicitation_code_hook {
      enable_code_hook_invocation = true
      invocation_label            = null
    }
    failure_next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "StartIntent"
      }
      intent {
        name = "FallbackIntent"
      }
    }
    failure_response {
      allow_interrupt = true
      message_group {
        message {
          plain_text_message {
            value = "I didn't understand your response. Please say yes or no."
          }
        }
      }
    }
    prompt_specification {
      allow_interrupt            = true
      max_retries                = 4
      message_selection_strategy = "Random"
      message_group {
        message {
          plain_text_message {
            value = "I have the appointment details for {PatientName} with a {Specialty} on {AppointmentDate} at {AppointmentTime}, using the phone number {PhoneNumber}. Would you like me to proceed?"
          }
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Initial"
        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }
        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }
          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }
        text_input_specification {
          start_timeout_ms = 30000
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry1"
        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }
        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }
          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }
        text_input_specification {
          start_timeout_ms = 30000
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry2"
        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }
        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }
          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }
        text_input_specification {
          start_timeout_ms = 30000
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry3"
        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }
        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }
          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }
        text_input_specification {
          start_timeout_ms = 30000
        }
      }
      prompt_attempts_specification {
        allow_interrupt = true
        map_block_key   = "Retry4"
        allowed_input_types {
          allow_audio_input = true
          allow_dtmf_input  = true
        }
        audio_and_dtmf_input_specification {
          start_timeout_ms = 4000
          audio_specification {
            end_timeout_ms = 640
            max_length_ms  = 15000
          }
          dtmf_specification {
            deletion_character = "*"
            end_character      = "#"
            end_timeout_ms     = 5000
            max_length         = 513
          }
        }
        text_input_specification {
          start_timeout_ms = 30000
        }
      }
    }
  }
  dialog_code_hook {
    enabled = true
  }
  fulfillment_code_hook {
    active  = true
    enabled = true
    post_fulfillment_status_specification {
      failure_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      failure_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "I couldn't complete the appointment request because the requested time or date may not be available. Please try another available appointment time or date."
            }
          }
        }
      }
      success_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      success_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "Your appointment request has been received successfully."
            }
          }
        }
      }
      timeout_next_step {
        session_attributes = null
        dialog_action {
          slot_to_elicit        = null
          suppress_next_message = null
          type                  = "EndConversation"
        }
        intent {
          name = null
        }
      }
      timeout_response {
        allow_interrupt = true
        message_group {
          message {
            plain_text_message {
              value = "The appointment service is taking longer than expected. Please try again."
            }
          }
        }
      }
    }
  }
  initial_response_setting {
    code_hook {
      active                      = true
      enable_code_hook_invocation = true
      invocation_label            = null
      post_code_hook_specification {
        failure_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
        success_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = "PatientName"
            suppress_next_message = null
            type                  = "ElicitSlot"
          }
          intent {
            name = null
          }
        }
        timeout_next_step {
          session_attributes = null
          dialog_action {
            slot_to_elicit        = null
            suppress_next_message = null
            type                  = "EndConversation"
          }
          intent {
            name = null
          }
        }
      }
    }
    next_step {
      session_attributes = null
      dialog_action {
        slot_to_elicit        = null
        suppress_next_message = null
        type                  = "InvokeDialogCodeHook"
      }
      intent {
        name = null
      }
    }
  }
  sample_utterance {
    utterance = "I want to book an appointment"
  }
  sample_utterance {
    utterance = "I need to book an appointment"
  }
  sample_utterance {
    utterance = "Book an appointment for me"
  }
  sample_utterance {
    utterance = "I want to see a doctor"
  }
  sample_utterance {
    utterance = "I need a doctor appointment"
  }
  sample_utterance {
    utterance = "Can I book a doctor appointment"
  }
  sample_utterance {
    utterance = "I want to schedule an appointment"
  }
  sample_utterance {
    utterance = "Help me book an appointment"
  }
  sample_utterance {
    utterance = "I need to schedule a doctor visit"
  }
  sample_utterance {
    utterance = "I want to make an appointment"
  }
  slot_priority {
    priority = 1
    slot_id  = "TTT04ABZLS"
  }
  slot_priority {
    priority = 2
    slot_id  = "DCLYDOHVEE"
  }
  slot_priority {
    priority = 3
    slot_id  = "XV0QSZILLR"
  }
  slot_priority {
    priority = 4
    slot_id  = "VECF4HPPPS"
  }
  slot_priority {
    priority = 5
    slot_id  = "ETDM3LOIQT"
  }
}
