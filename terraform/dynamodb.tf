resource "aws_dynamodb_table" "appointments" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "PhoneNumber"
  range_key = "AppointmentDateTime"

  attribute {
    name = "PhoneNumber"
    type = "S"
  }

  attribute {
    name = "AppointmentDateTime"
    type = "S"
  }

  attribute {
    name = "DoctorSlot"
    type = "S"
  }

  attribute {
    name = "AppointmentTime"
    type = "S"
  }

  global_secondary_index {
    name            = "DoctorSlotIndex"
    hash_key        = "DoctorSlot"
    range_key       = "AppointmentTime"
    projection_type = "ALL"
  }

  lifecycle {
    prevent_destroy = true
  }
}
