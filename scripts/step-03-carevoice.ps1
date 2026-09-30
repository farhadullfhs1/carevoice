$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " CareVoice - Step 3" -ForegroundColor Cyan
Write-Host " Local Conversation Engine" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LambdaPath = Join-Path $ProjectRoot "lambda"
$DataPath = Join-Path $LambdaPath "data"
$TestsPath = Join-Path $LambdaPath "tests"

# ------------------------------------------------------------
# 1. Create required directories
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $DataPath | Out-Null
New-Item -ItemType Directory -Force -Path $TestsPath | Out-Null

Write-Host "[1/8] Directories ready." -ForegroundColor Green

# ------------------------------------------------------------
# 2. Synthetic patient interaction database
# ------------------------------------------------------------

@'
{
  "patients": [
    {
      "patient_id": "P1001",
      "name": "Aisha Khan",
      "date_of_birth": "1995-04-18",
      "phone": "+91-9000000001",
      "preferred_doctor": "Dr. Sharma",
      "preferred_specialty": "Cardiology",
      "preferred_time": "morning",
      "interaction_profile": {
        "frequently_requested_services": [
          "cardiology appointments",
          "appointment availability"
        ],
        "previous_doctors": [
          "Dr. Sharma"
        ],
        "preferred_appointment_times": [
          "morning"
        ],
        "common_questions": [
          "doctor availability",
          "appointment availability"
        ],
        "required_information_patterns": [
          "appointment date",
          "preferred time"
        ]
      }
    },
    {
      "patient_id": "P1002",
      "name": "Rahul Mehta",
      "date_of_birth": "1988-11-02",
      "phone": "+91-9000000002",
      "preferred_doctor": "Dr. Patel",
      "preferred_specialty": "Dermatology",
      "preferred_time": "afternoon",
      "interaction_profile": {
        "frequently_requested_services": [
          "dermatology appointments"
        ],
        "previous_doctors": [
          "Dr. Patel"
        ],
        "preferred_appointment_times": [
          "afternoon"
        ],
        "common_questions": [
          "doctor availability"
        ],
        "required_information_patterns": [
          "appointment date"
        ]
      }
    }
  ]
}
'@ | Set-Content -Path (Join-Path $DataPath "patients.json") -Encoding UTF8

# ------------------------------------------------------------
# 3. Synthetic doctor database
# ------------------------------------------------------------

@'
{
  "doctors": [
    {
      "doctor_id": "D1001",
      "name": "Dr. Sharma",
      "specialty": "Cardiology",
      "availability": {
        "2026-09-28": ["09:30", "11:00", "15:00"],
        "2026-09-29": ["09:30", "14:00"]
      }
    },
    {
      "doctor_id": "D1002",
      "name": "Dr. Patel",
      "specialty": "Dermatology",
      "availability": {
        "2026-09-28": ["10:00", "13:30", "16:00"],
        "2026-09-29": ["10:30", "15:30"]
      }
    },
    {
      "doctor_id": "D1003",
      "name": "Dr. Iyer",
      "specialty": "General Medicine",
      "availability": {
        "2026-09-28": ["09:00", "12:00", "17:00"],
        "2026-09-29": ["09:30", "11:30", "16:30"]
      }
    }
  ]
}
'@ | Set-Content -Path (Join-Path $DataPath "doctors.json") -Encoding UTF8

# ------------------------------------------------------------
# 4. Synthetic appointment database
# ------------------------------------------------------------

@'
{
  "appointments": [
    {
      "appointment_id": "A1001",
      "patient_id": "P1001",
      "doctor_id": "D1001",
      "doctor_name": "Dr. Sharma",
      "specialty": "Cardiology",
      "date": "2026-09-29",
      "time": "09:30",
      "status": "CONFIRMED"
    },
    {
      "appointment_id": "A1002",
      "patient_id": "P1002",
      "doctor_id": "D1002",
      "doctor_name": "Dr. Patel",
      "specialty": "Dermatology",
      "date": "2026-09-28",
      "time": "13:30",
      "status": "CONFIRMED"
    }
  ]
}
'@ | Set-Content -Path (Join-Path $DataPath "appointments.json") -Encoding UTF8

Write-Host "[2/8] Synthetic patient, doctor, and appointment data created." -ForegroundColor Green

# ------------------------------------------------------------
# 5. Lex response helper
# ------------------------------------------------------------

@'
def message(content):
    return {
        "contentType": "PlainText",
        "content": content
    }


def response(
    dialog_type,
    intent_name=None,
    slots=None,
    message_text=None,
    slot_to_elicit=None,
    intent_state=None,
    session_attributes=None
):
    session_state = {
        "dialogAction": {
            "type": dialog_type
        }
    }

    if slot_to_elicit:
        session_state["dialogAction"]["slotToElicit"] = slot_to_elicit

    if intent_name:
        session_state["intent"] = {
            "name": intent_name,
            "slots": slots or {}
        }

        if intent_state:
            session_state["intent"]["state"] = intent_state

    if session_attributes is not None:
        session_state["sessionAttributes"] = session_attributes

    result = {
        "sessionState": session_state
    }

    if message_text:
        result["messages"] = [message(message_text)]

    return result
'@ | Set-Content -Path (Join-Path $LambdaPath "lex_response.py") -Encoding UTF8

# ------------------------------------------------------------
# 6. Interaction/context engine
# ------------------------------------------------------------

@'
import json
import os


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")


def load_json(filename):
    path = os.path.join(DATA_DIR, filename)

    with open(path, "r", encoding="utf-8-sig") as file:
        return json.load(file)


def load_patient(patient_id):
    data = load_json("patients.json")

    for patient in data["patients"]:
        if patient["patient_id"] == patient_id:
            return patient

    return None


def load_doctors():
    return load_json("doctors.json")["doctors"]


def load_appointments():
    return load_json("appointments.json")["appointments"]


def get_slot_value(slots, name):
    slot = slots.get(name)

    if not slot:
        return None

    value = slot.get("value")

    if not value:
        return None

    return value.get("interpretedValue") or value.get("originalValue")


def make_slot(value):
    if value is None:
        return None

    return {
        "value": {
            "originalValue": str(value),
            "interpretedValue": str(value),
            "resolvedValues": [str(value)]
        }
    }


def apply_patient_context(slots):
    patient_id = get_slot_value(slots, "patientId")

    if not patient_id:
        return slots, None

    patient = load_patient(patient_id)

    if not patient:
        return slots, None

    context_map = {
        "doctorName": patient.get("preferred_doctor"),
        "specialty": patient.get("preferred_specialty"),
        "preferredTime": patient.get("preferred_time")
    }

    for slot_name, value in context_map.items():
        if value and not get_slot_value(slots, slot_name):
            slots[slot_name] = make_slot(value)

    return slots, patient


def find_doctor(name=None, specialty=None):
    for doctor in load_doctors():
        if name and doctor["name"].lower() == name.lower():
            return doctor

        if specialty and doctor["specialty"].lower() == specialty.lower():
            return doctor

    return None


def get_available_slots(doctor, date):
    if not doctor:
        return []

    return doctor.get("availability", {}).get(date, [])


def get_patient_appointments(patient_id):
    return [
        appointment
        for appointment in load_appointments()
        if appointment["patient_id"] == patient_id
        and appointment["status"] == "CONFIRMED"
    ]
'@ | Set-Content -Path (Join-Path $LambdaPath "interaction_engine.py") -Encoding UTF8

# ------------------------------------------------------------
# 7. Main Lambda handler
# ------------------------------------------------------------

@'
import json
import logging

from interaction_engine import (
    apply_patient_context,
    find_doctor,
    get_available_slots,
    get_patient_appointments,
    get_slot_value,
    load_patient
)

from lex_response import response


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("CareVoice Lambda invoked")

    session_state = event.get("sessionState", {})
    intent = session_state.get("intent", {})

    intent_name = intent.get("name", "FallbackIntent")
    slots = intent.get("slots") or {}
    invocation_source = event.get("invocationSource", "DialogCodeHook")

    if intent_name == "BookAppointmentIntent":
        return handle_book_appointment(invocation_source, intent_name, slots)

    if intent_name == "CheckAppointmentIntent":
        return handle_check_appointment(intent_name, slots)

    if intent_name == "AppointmentAvailabilityIntent":
        return handle_appointment_availability(intent_name, slots)

    if intent_name == "DoctorAvailabilityIntent":
        return handle_doctor_availability(intent_name, slots)

    if intent_name == "PatientInformationIntent":
        return handle_patient_information(intent_name, slots)

    if intent_name == "HelpIntent":
        return response(
            "ElicitIntent",
            message_text=(
                "I can help you book an appointment, check an appointment, "
                "find appointment availability, check doctor availability, "
                "or provide patient information. What would you like to do?"
            )
        )

    return response(
        "ElicitIntent",
        message_text=(
            "I'm sorry, I didn't understand that. You can ask me to book "
            "an appointment, check an appointment, or find doctor availability."
        )
    )


def handle_book_appointment(invocation_source, intent_name, slots):
    slots, patient = apply_patient_context(slots)

    if not patient:
        patient_id = get_slot_value(slots, "patientId")

        if not patient_id:
            return response(
                "ElicitSlot",
                intent_name,
                slots,
                "May I have your patient ID?",
                "patientId"
            )

        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find that patient ID.",
            intent_state="Failed"
        )

    required = [
        ("specialty", "What medical specialty do you need?"),
        ("appointmentDate", "What date would you prefer?"),
        ("preferredTime", "What time would you prefer?")
    ]

    for slot_name, prompt in required:
        if not get_slot_value(slots, slot_name):
            return response(
                "ElicitSlot",
                intent_name,
                slots,
                prompt,
                slot_name
            )

    doctor_name = get_slot_value(slots, "doctorName")
    specialty = get_slot_value(slots, "specialty")
    date = get_slot_value(slots, "appointmentDate")
    preferred_time = get_slot_value(slots, "preferredTime")

    doctor = find_doctor(name=doctor_name, specialty=specialty)

    if not doctor:
        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find a doctor matching that specialty.",
            intent_state="Failed"
        )

    available = get_available_slots(doctor, date)

    if not available:
        return response(
            "Close",
            intent_name,
            slots,
            f"{doctor['name']} has no available appointments on {date}.",
            intent_state="Failed"
        )

    selected_time = preferred_time.lower()

    if selected_time == "morning":
        morning = [
            slot for slot in available
            if int(slot.split(":")[0]) < 12
        ]
        selected_time = morning[0] if morning else available[0]

    elif selected_time == "afternoon":
        afternoon = [
            slot for slot in available
            if 12 <= int(slot.split(":")[0]) < 17
        ]
        selected_time = afternoon[0] if afternoon else available[0]

    elif selected_time == "evening":
        evening = [
            slot for slot in available
            if int(slot.split(":")[0]) >= 17
        ]
        selected_time = evening[0] if evening else available[0]

    elif selected_time not in available:
        selected_time = available[0]

    if invocation_source == "DialogCodeHook":
        return response("Delegate", intent_name, slots)

    return response(
        "Close",
        intent_name,
        slots,
        (
            f"Your appointment request is ready for {doctor['name']} "
            f"on {date} at {selected_time}."
        ),
        intent_state="Fulfilled"
    )


def handle_check_appointment(intent_name, slots):
    patient_id = get_slot_value(slots, "patientId")

    if not patient_id:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "May I have your patient ID?",
            "patientId"
        )

    patient = load_patient(patient_id)

    if not patient:
        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find that patient ID.",
            intent_state="Failed"
        )

    appointments = get_patient_appointments(patient_id)

    if not appointments:
        return response(
            "Close",
            intent_name,
            slots,
            "You don't currently have any confirmed appointments.",
            intent_state="Fulfilled"
        )

    appointment = appointments[0]

    return response(
        "Close",
        intent_name,
        slots,
        (
            f"Your appointment is with {appointment['doctor_name']} "
            f"for {appointment['specialty']} on {appointment['date']} "
            f"at {appointment['time']}."
        ),
        intent_state="Fulfilled"
    )


def handle_appointment_availability(intent_name, slots):
    specialty = get_slot_value(slots, "specialty")
    date = get_slot_value(slots, "appointmentDate")

    if not specialty:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "Which medical specialty are you looking for?",
            "specialty"
        )

    if not date:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "What date would you like to check?",
            "appointmentDate"
        )

    doctor = find_doctor(specialty=specialty)

    if not doctor:
        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find a doctor for that specialty.",
            intent_state="Failed"
        )

    available = get_available_slots(doctor, date)

    if available:
        text = (
            f"I found {len(available)} available appointment times "
            f"for {specialty} on {date}: {', '.join(available)}."
        )
    else:
        text = f"There are no available appointments for {specialty} on {date}."

    return response(
        "Close",
        intent_name,
        slots,
        text,
        intent_state="Fulfilled"
    )


def handle_doctor_availability(intent_name, slots):
    doctor_name = get_slot_value(slots, "doctorName")
    date = get_slot_value(slots, "appointmentDate")

    if not doctor_name:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "Which doctor would you like to check?",
            "doctorName"
        )

    if not date:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "What date would you like to check?",
            "appointmentDate"
        )

    doctor = find_doctor(name=doctor_name)

    if not doctor:
        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find that doctor.",
            intent_state="Failed"
        )

    available = get_available_slots(doctor, date)

    if available:
        text = (
            f"{doctor['name']} is available on {date} at: "
            f"{', '.join(available)}."
        )
    else:
        text = f"{doctor['name']} has no available appointments on {date}."

    return response(
        "Close",
        intent_name,
        slots,
        text,
        intent_state="Fulfilled"
    )


def handle_patient_information(intent_name, slots):
    patient_id = get_slot_value(slots, "patientId")

    if not patient_id:
        return response(
            "ElicitSlot",
            intent_name,
            slots,
            "May I have your patient ID?",
            "patientId"
        )

    patient = load_patient(patient_id)

    if not patient:
        return response(
            "Close",
            intent_name,
            slots,
            "I couldn't find that patient ID.",
            intent_state="Failed"
        )

    return response(
        "Close",
        intent_name,
        slots,
        (
            f"I have your preferred doctor as {patient['preferred_doctor']}, "
            f"your preferred specialty as {patient['preferred_specialty']}, "
            f"and your preferred appointment time as "
            f"{patient['preferred_time']}."
        ),
        intent_state="Fulfilled"
    )
'@ | Set-Content -Path (Join-Path $LambdaPath "handler.py") -Encoding UTF8

# ------------------------------------------------------------
# 8. Test suite
# ------------------------------------------------------------

@'
import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BASE_DIR)

from handler import lambda_handler


def slot(value):
    return {
        "value": {
            "originalValue": value,
            "interpretedValue": value,
            "resolvedValues": [value]
        }
    }


def event(intent_name, slots=None, invocation_source="DialogCodeHook"):
    return {
        "messageVersion": "1.0",
        "invocationSource": invocation_source,
        "inputMode": "Text",
        "sessionId": "local-test-session",
        "inputTranscript": "local test",
        "sessionState": {
            "intent": {
                "name": intent_name,
                "state": "InProgress",
                "slots": slots or {}
            }
        }
    }


def action(result):
    return result["sessionState"]["dialogAction"]["type"]


def run():
    passed = 0

    result = lambda_handler(
        event(
            "BookAppointmentIntent",
            {"patientId": slot("P1001")}
        ),
        None
    )

    assert action(result) == "ElicitSlot"
    assert result["sessionState"]["dialogAction"]["slotToElicit"] == "appointmentDate"
    passed += 1

    result = lambda_handler(
        event(
            "BookAppointmentIntent",
            {
                "patientId": slot("P1001"),
                "specialty": slot("Cardiology"),
                "appointmentDate": slot("2026-09-28"),
                "preferredTime": slot("morning")
            },
            "FulfillmentCodeHook"
        ),
        None
    )

    assert action(result) == "Close"
    assert result["sessionState"]["intent"]["state"] == "Fulfilled"
    passed += 1

    result = lambda_handler(
        event(
            "CheckAppointmentIntent",
            {"patientId": slot("P1001")}
        ),
        None
    )

    assert action(result) == "Close"
    assert "Dr. Sharma" in result["messages"][0]["content"]
    passed += 1

    result = lambda_handler(
        event(
            "AppointmentAvailabilityIntent",
            {
                "specialty": slot("Cardiology"),
                "appointmentDate": slot("2026-09-28")
            }
        ),
        None
    )

    assert action(result) == "Close"
    assert "09:30" in result["messages"][0]["content"]
    passed += 1

    result = lambda_handler(
        event(
            "DoctorAvailabilityIntent",
            {
                "doctorName": slot("Dr. Sharma"),
                "appointmentDate": slot("2026-09-28")
            }
        ),
        None
    )

    assert action(result) == "Close"
    assert "Dr. Sharma" in result["messages"][0]["content"]
    passed += 1

    result = lambda_handler(
        event(
            "PatientInformationIntent",
            {"patientId": slot("P1001")}
        ),
        None
    )

    assert action(result) == "Close"
    assert "preferred doctor" in result["messages"][0]["content"]
    passed += 1

    result = lambda_handler(event("HelpIntent"), None)

    assert action(result) == "ElicitIntent"
    passed += 1

    result = lambda_handler(event("UnknownIntent"), None)

    assert action(result) == "ElicitIntent"
    passed += 1

    print("")
    print("=============================================")
    print(f" CAREVOICE TESTS PASSED: {passed}/8")
    print("=============================================")

    return 0


if __name__ == "__main__":
    raise SystemExit(run())
'@ | Set-Content -Path (Join-Path $TestsPath "test_handler.py") -Encoding UTF8

# ------------------------------------------------------------
# 9. Lex-compatible sample event
# ------------------------------------------------------------

@'
{
  "messageVersion": "1.0",
  "invocationSource": "DialogCodeHook",
  "inputMode": "Text",
  "sessionId": "carevoice-local-test-001",
  "inputTranscript": "I want to book an appointment",
  "sessionState": {
    "intent": {
      "name": "BookAppointmentIntent",
      "state": "InProgress",
      "slots": {
        "patientId": {
          "value": {
            "originalValue": "P1001",
            "interpretedValue": "P1001",
            "resolvedValues": ["P1001"]
          }
        }
      }
    }
  }
}
'@ | Set-Content -Path (Join-Path $LambdaPath "test_event.json") -Encoding UTF8

# ------------------------------------------------------------
# 10. Lambda requirements
# ------------------------------------------------------------

@'
# No third-party dependencies are required for the current local engine.
# The implementation uses the Python standard library.
'@ | Set-Content -Path (Join-Path $LambdaPath "requirements.txt") -Encoding UTF8

Write-Host "[3/8] Lambda implementation created." -ForegroundColor Green
Write-Host "[4/8] Lex-compatible test event created." -ForegroundColor Green
Write-Host "[5/8] Test suite created." -ForegroundColor Green

# ------------------------------------------------------------
# 11. Validate JSON
# ------------------------------------------------------------

Write-Host ""
Write-Host "Validating JSON..." -ForegroundColor Yellow

Get-ChildItem -Path $DataPath -Filter "*.json" | ForEach-Object {
    Get-Content $_.FullName -Raw | ConvertFrom-Json | Out-Null
    Write-Host "PASS: $($_.Name)" -ForegroundColor Green
}

Get-Content (Join-Path $LambdaPath "test_event.json") -Raw |
    ConvertFrom-Json | Out-Null

Write-Host "PASS: test_event.json" -ForegroundColor Green

# ------------------------------------------------------------
# 12. Run tests
# ------------------------------------------------------------

Write-Host ""
Write-Host "Running CareVoice tests..." -ForegroundColor Yellow
Write-Host ""

Push-Location $LambdaPath

try {
    python tests\test_handler.py

    if ($LASTEXITCODE -ne 0) {
        throw "CareVoice test suite failed."
    }
}
finally {
    Pop-Location
}

Write-Host ""
Write-Host "[6/8] Automated tests passed." -ForegroundColor Green

# ------------------------------------------------------------
# 13. Remove Python cache
# ------------------------------------------------------------

Get-ChildItem -Path $LambdaPath -Directory -Filter "__pycache__" -Recurse -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force

Write-Host "[7/8] Python cache cleaned." -ForegroundColor Green

# ------------------------------------------------------------
# 14. Final verification
# ------------------------------------------------------------

$RequiredFiles = @(
    "lambda\handler.py",
    "lambda\lex_response.py",
    "lambda\interaction_engine.py",
    "lambda\data\patients.json",
    "lambda\data\doctors.json",
    "lambda\data\appointments.json",
    "lambda\tests\test_handler.py",
    "lambda\test_event.json"
)

foreach ($file in $RequiredFiles) {
    $fullPath = Join-Path $ProjectRoot $file

    if (-not (Test-Path $fullPath)) {
        throw "Required file missing: $file"
    }
}

Write-Host "[8/8] Required files verified." -ForegroundColor Green

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host " CAREVOICE STEP 3 COMPLETE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "The local CareVoice conversation engine is ready." -ForegroundColor White
Write-Host ""
Write-Host "Next step: connect these intents to Amazon Lex V2." -ForegroundColor Cyan
Write-Host ""
