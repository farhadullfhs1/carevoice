resource "aws_lexv2models_slot_type" "hospital_info" {
  bot_id      = aws_lexv2models_bot.carevoice.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.carevoice.locale_id

  name        = "HospitalInfoType"
  description = "Types of hospital information requested by users."

  slot_type_values {
    sample_value {
      value = "Timings"
    }

    synonyms {
      value = "opening hours, working hours, hospital hours"
    }
  }

  slot_type_values {
    sample_value {
      value = "Location"
    }

    synonyms {
      value = "address, where is hospital, hospital location"
    }
  }

  slot_type_values {
    sample_value {
      value = "Services"
    }

    synonyms {
      value = "facilities, hospital services"
    }
  }

  slot_type_values {
    sample_value {
      value = "Departments"
    }

    synonyms {
      value = "departments, specialties"
    }
  }

  slot_type_values {
    sample_value {
      value = "Contact"
    }

    synonyms {
      value = "phone number, contact number"
    }
  }

  slot_type_values {
    sample_value {
      value = "Emergency"
    }

    synonyms {
      value = "emergency services, emergency care"
    }
  }

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }
}


resource "aws_lexv2models_slot_type" "medical_specialty" {
  bot_id      = aws_lexv2models_bot.carevoice.id
  bot_version = "DRAFT"
  locale_id   = aws_lexv2models_bot_locale.carevoice.locale_id

  name        = "MedicalSpecialty"
  description = "Medical specialties available for appointment booking."

  slot_type_values {
    sample_value {
      value = "Cardiologist"
    }

    synonyms {
      value = "heart doctor, heart specialist"
    }
  }

  slot_type_values {
    sample_value {
      value = "General Physician"
    }

    synonyms {
      value = "GP, general doctor, physician"
    }
  }

  slot_type_values {
    sample_value {
      value = "Dermatologist"
    }

    synonyms {
      value = "skin doctor, skin specialist, hair treatment,nails treatment, skin treatment"
    }
  }

  slot_type_values {
    sample_value {
      value = "Dentist"
    }

    synonyms {
      value = "dental doctor"
    }
  }

  slot_type_values {
    sample_value {
      value = "Ophthalmologist"
    }

    synonyms {
      value = "eye doctor, eye specialist"
    }
  }

  slot_type_values {
    sample_value {
      value = "Orthopedic"
    }

    synonyms {
      value = "bone doctor, orthopedic doctor"
    }
  }

  slot_type_values {
    sample_value {
      value = "Pediatrician"
    }

    synonyms {
      value = "child doctor, children doctor"
    }
  }

  slot_type_values {
    sample_value {
      value = "Gynecologist"
    }

    synonyms {
      value = "women's doctor, gyne doctor, pregnancy"
    }
  }

  slot_type_values {
    sample_value {
      value = "Neurologist"
    }

    synonyms {
      value = "brain doctor, nerve doctor"
    }
  }

  slot_type_values {
    sample_value {
      value = "ENT"
    }

    synonyms {
      value = "ear ,nose ,throat doctor"
    }
  }

  value_selection_setting {
    resolution_strategy = "TopResolution"
  }
}
