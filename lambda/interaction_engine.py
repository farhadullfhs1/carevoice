import json
import os
import re
import uuid

import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError


BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)

DATA_DIR = os.path.join(
    BASE_DIR,
    "data",
)

TABLE_NAME = os.environ.get(
    "CAREVOICE_APPOINTMENTS_TABLE",
)

AWS_REGION = os.environ.get(
    "AWS_REGION",
    "ap-northeast-2",
)

_dynamodb = None
_table = None


SPECIALTY_ALIASES = {
    "general physician": "General Medicine",
    "general doctor": "General Medicine",
    "physician": "General Medicine",
    "general medicine": "General Medicine",

    "cardiologist": "Cardiology",
    "cardiology": "Cardiology",

    "dermatologist": "Dermatology",
    "dermatology": "Dermatology",

    "dentist": "Dentistry",
    "dental": "Dentistry",
    "dentistry": "Dentistry",

    "ophthalmologist": "Ophthalmology",
    "eye doctor": "Ophthalmology",
    "eye specialist": "Ophthalmology",
    "ophthalmology": "Ophthalmology",

    "orthopedic": "Orthopedics",
    "orthopaedic": "Orthopedics",
    "bone doctor": "Orthopedics",
    "orthopedics": "Orthopedics",

    "pediatrician": "Pediatrics",
    "child doctor": "Pediatrics",
    "children doctor": "Pediatrics",
    "pediatrics": "Pediatrics",

    "gynecologist": "Gynecology",
    "gynecology": "Gynecology",
    "gyne doctor": "Gynecology",
    "women's doctor": "Gynecology",

    "neurologist": "Neurology",
    "brain doctor": "Neurology",
    "nerve doctor": "Neurology",
    "neurology": "Neurology",

    "ent": "ENT",
    "ear nose throat doctor": "ENT",
}


def normalize_text(value):
    if value is None:
        return ""

    return re.sub(
        r"\s+",
        " ",
        str(value).strip().lower(),
    )


def normalize_phone(value):
    return re.sub(
        r"\D",
        "",
        str(value or ""),
    )


def normalize_specialty(value):

    normalized = normalize_text(value)

    return SPECIALTY_ALIASES.get(
        normalized,
        str(value).strip()
        if value
        else "",
    )


def load_json(filename):

    path = os.path.join(
        DATA_DIR,
        filename,
    )

    with open(
        path,
        "r",
        encoding="utf-8-sig",
    ) as file:

        return json.load(file)


def load_doctors():

    return load_json(
        "doctors.json"
    ).get(
        "doctors",
        [],
    )


def load_patients():

    return load_json(
        "patients.json"
    ).get(
        "patients",
        [],
    )


def load_appointments():

    return load_json(
        "appointments.json"
    ).get(
        "appointments",
        [],
    )


def get_slot_value(slots, name):

    slot = slots.get(name)

    if not slot:
        return None

    value = slot.get("value")

    if not value:
        return None

    return (
        value.get("interpretedValue")
        or value.get("originalValue")
    )


def find_patient_by_name_and_phone(
    patient_name,
    phone_number,
):

    target_name = normalize_text(
        patient_name
    )

    target_phone = normalize_phone(
        phone_number
    )

    for patient in load_patients():

        if (
            normalize_text(
                patient.get("name")
            ) == target_name
            and
            normalize_phone(
                patient.get("phone")
            ) == target_phone
        ):
            return patient

    return None


def find_doctor_by_specialty(
    specialty
):

    target = normalize_specialty(
        specialty
    )

    for doctor in load_doctors():

        doctor_specialty = normalize_specialty(
            doctor.get("specialty")
        )

        if normalize_text(
            doctor_specialty
        ) == normalize_text(target):

            return doctor

    return None


def find_doctor_by_name(name):

    target = normalize_text(name)

    for doctor in load_doctors():

        if normalize_text(
            doctor.get("name")
        ) == target:

            return doctor

    return None


def find_doctor(
    name=None,
    specialty=None,
):

    if name:

        doctor = find_doctor_by_name(
            name
        )

        if doctor:
            return doctor

    if specialty:

        return find_doctor_by_specialty(
            specialty
        )

    return None


def normalize_time(value):

    if value is None:
        return ""

    value = str(value).strip().lower()

    value = value.replace(
        " ",
        "",
    )

    value = value.replace(
        ".",
        ":",
    )

    # Handles:
    # 12pm
    # 12am
    # 12:00pm
    # 12:00am
    # 12:30
    # 12:30pm

    match = re.fullmatch(
        r"(\d{1,2})(?::?(\d{2}))?(am|pm)?",
        value,
    )

    if not match:
        return str(value)

    hour = int(match.group(1))

    minute_text = match.group(2)

    minute = (
        int(minute_text)
        if minute_text
        else 0
    )

    period = match.group(3)

    if period == "pm" and hour < 12:
        hour += 12

    if period == "am" and hour == 12:
        hour = 0

    return f"{hour:02d}:{minute:02d}"


def get_available_slots(
    doctor,
    appointment_date,
):

    if not doctor:
        return []

    return [
        normalize_time(slot)
        for slot in doctor.get(
            "availability",
            {},
        ).get(
            str(appointment_date),
            [],
        )
    ]


def get_available_dates(doctor):

    if not doctor:
        return []

    return sorted(
        doctor.get(
            "availability",
            {},
        ).keys()
    )


def get_next_available_dates(
    doctor,
    requested_date,
):

    dates = get_available_dates(
        doctor
    )

    return [
        date
        for date in dates
        if date > str(requested_date)
    ][:3]


def get_dynamodb_table():

    global _dynamodb
    global _table

    if not TABLE_NAME:
        return None

    if _table is None:

        _dynamodb = boto3.resource(
            "dynamodb",
            region_name=AWS_REGION,
        )

        _table = _dynamodb.Table(
            TABLE_NAME
        )

    return _table


def dynamodb_enabled():

    return bool(TABLE_NAME)


def dynamodb_slot_exists(
    doctor_id,
    appointment_date,
    appointment_time,
):

    table = get_dynamodb_table()

    if table is None:
        return False

    doctor_slot = (
        f"{doctor_id}#{appointment_date}"
    )

    try:

        result = table.query(
            IndexName="DoctorSlotIndex",
            KeyConditionExpression=(
                Key("DoctorSlot").eq(
                    doctor_slot
                )
                &
                Key("AppointmentTime").eq(
                    appointment_time
                )
            ),
            Limit=1,
        )

        return bool(
            result.get("Items")
        )

    except ClientError:

        raise


def build_appointment(
    patient_name,
    phone_number,
    doctor,
    specialty,
    appointment_date,
    appointment_time,
):

    appointment_id = (
        "A"
        + uuid.uuid4()
        .hex[:10]
        .upper()
    )

    return {
        "appointment_id": appointment_id,
        "patient_name": str(
            patient_name
        ),
        "phone_number": normalize_phone(
            phone_number
        ),
        "doctor_id": doctor.get(
            "doctor_id"
        ) or doctor.get(
            "name",
            "",
        ),
        "doctor_name": doctor.get(
            "name",
            "",
        ),
        "specialty": doctor.get(
            "specialty",
            normalize_specialty(
                specialty
            ),
        ),
        "date": str(
            appointment_date
        ),
        "time": str(
            appointment_time
        ),
        "status": "CONFIRMED",
    }


def save_appointment(
    appointment
):

    table = get_dynamodb_table()

    if table is None:

        return {
            "success": False,
            "message": (
                "Appointment storage is not "
                "configured."
            ),
        }

    appointment_datetime = (
        f"{appointment['date']}"
        f"T"
        f"{appointment['time']}"
    )

    doctor_slot = (
        f"{appointment['doctor_name']}"
        f"#"
        f"{appointment['date']}"
    )

    item = {
        "PhoneNumber": appointment[
            "phone_number"
        ],

        "AppointmentDateTime":
            appointment_datetime,

        "AppointmentId":
            appointment[
                "appointment_id"
            ],

        "PatientName":
            appointment[
                "patient_name"
            ],

        "DoctorId":
            appointment[
                "doctor_id"
            ],

        "DoctorName":
            appointment[
                "doctor_name"
            ],

        "Specialty":
            appointment[
                "specialty"
            ],

        "AppointmentDate":
            appointment[
                "date"
            ],

        "AppointmentTime":
            appointment[
                "time"
            ],

        "DoctorSlot":
            doctor_slot,

        "Status":
            appointment[
                "status"
            ],
    }

    try:

        table.put_item(
            Item=item,
            ConditionExpression=(
                "attribute_not_exists("
                "PhoneNumber"
                ")"
            ),
        )

        return {
            "success": True,
            "appointment": appointment,
        }

    except ClientError as error:

        code = error.response[
            "Error"
        ].get(
            "Code"
        )

        if code == (
            "ConditionalCheckFailedException"
        ):

            return {
                "success": False,
                "message": (
                    "You already have an "
                    "appointment at this "
                    "date and time."
                ),
                "reason": "DUPLICATE",
            }

        raise


def book_appointment(
    patient_name,
    specialty,
    appointment_date,
    appointment_time,
    phone_number,
    persist=False,
):

    specialty_normalized = (
        normalize_specialty(
            specialty
        )
    )

    requested_time = normalize_time(
        appointment_time
    )

    doctor = find_doctor_by_specialty(
        specialty_normalized
    )

    if not doctor:

        return {
            "success": False,
            "message": (
                f"I couldn't find a doctor "
                f"for the {specialty} specialty."
            ),
            "reason": "DOCTOR_NOT_FOUND",
        }

    available = get_available_slots(
        doctor,
        appointment_date,
    )

    if not available:

        alternative_dates = (
            get_next_available_dates(
                doctor,
                appointment_date,
            )
        )

        return {
            "success": False,
            "message": (
                f"There are no available "
                f"appointments with "
                f"{doctor['name']} on "
                f"{appointment_date}."
            ),
            "reason": "NO_DATE_AVAILABILITY",
            "doctor": doctor,
            "date": str(
                appointment_date
            ),
            "alternative_dates":
                alternative_dates,
        }

    if requested_time not in available:

        return {
            "success": False,
            "message": (
                f"{requested_time} is not "
                f"available."
            ),
            "reason": "TIME_UNAVAILABLE",
            "doctor": doctor,
            "date": str(
                appointment_date
            ),
            "requested_time":
                requested_time,
            "alternative_times":
                available,
        }

    # Check the original JSON dataset too.
    for existing in load_appointments():

        if (
            str(existing.get("doctor_id"))
            == str(doctor.get("doctor_id"))
            and
            str(existing.get("date"))
            == str(appointment_date)
            and
            normalize_time(
                existing.get("time")
            ) == requested_time
            and
            existing.get("status")
            == "CONFIRMED"
        ):

            return {
                "success": False,
                "message": (
                    f"{requested_time} is "
                    f"already booked with "
                    f"{doctor['name']} on "
                    f"{appointment_date}."
                ),
                "reason":
                    "TIME_UNAVAILABLE",
                "doctor": doctor,
                "date": str(
                    appointment_date
                ),
                "requested_time":
                    requested_time,
                "alternative_times":
                    [
                        slot
                        for slot in available
                        if slot
                        != requested_time
                    ],
            }

    # Check live DynamoDB bookings.
    if dynamodb_enabled():

        doctor_key = (
            doctor.get("doctor_id")
            or doctor.get("name", "")
        )

        if dynamodb_slot_exists(
            doctor_key,
            str(appointment_date),
            requested_time,
        ):

            return {
                "success": False,
                "message": (
                    f"{requested_time} is "
                    f"already booked with "
                    f"{doctor['name']} on "
                    f"{appointment_date}."
                ),
                "reason":
                    "TIME_UNAVAILABLE",
                "doctor": doctor,
                "date": str(
                    appointment_date
                ),
                "requested_time":
                    requested_time,
                "alternative_times":
                    [
                        slot
                        for slot in available
                        if slot
                        != requested_time
                    ],
            }

    appointment = build_appointment(
        patient_name,
        phone_number,
        doctor,
        specialty_normalized,
        appointment_date,
        requested_time,
    )

    if persist:

        saved = save_appointment(
            appointment
        )

        if not saved["success"]:
            return saved

    return {
        "success": True,
        "appointment": appointment,
        "message": (
            "Appointment request "
            "validated successfully."
        ),
    }


def find_dynamodb_appointment(
    patient_name,
    phone_number,
):

    table = get_dynamodb_table()

    if table is None:
        return None

    normalized_phone = normalize_phone(
        phone_number
    )

    try:

        result = table.query(
            KeyConditionExpression=(
                Key("PhoneNumber").eq(
                    normalized_phone
                )
            ),
            ConsistentRead=True,
        )

    except ClientError:

        raise

    target_name = normalize_text(
        patient_name
    )

    matches = []

    for item in result.get(
        "Items",
        [],
    ):

        if (
            normalize_text(
                item.get("PatientName")
            )
            == target_name
        ):

            matches.append(item)

    if not matches:
        return None

    matches.sort(
        key=lambda item:
            item.get(
                "AppointmentDateTime",
                "",
            )
    )

    return matches[0]


def find_json_appointment(
    patient_name,
    phone_number,
):

    patient = find_patient_by_name_and_phone(
        patient_name,
        phone_number,
    )

    if not patient:
        return None

    patient_id = patient.get(
        "patient_id"
    )

    appointments = [
        appointment
        for appointment in load_appointments()
        if appointment.get(
            "patient_id"
        ) == patient_id
        and appointment.get(
            "status"
        ) == "CONFIRMED"
    ]

    if not appointments:
        return None

    appointment = appointments[0]

    return {
        "appointment_id":
            appointment.get(
                "appointment_id",
                "",
            ),
        "patient_name":
            patient.get(
                "name",
                patient_name,
            ),
        "phone_number":
            patient.get(
                "phone",
                phone_number,
            ),
        "doctor_name":
            appointment.get(
                "doctor_name",
                "",
            ),
        "specialty":
            appointment.get(
                "specialty",
                "",
            ),
        "date":
            appointment.get(
                "date",
                "",
            ),
        "time":
            normalize_time(
                appointment.get(
                    "time",
                    "",
                )
            ),
        "status":
            appointment.get(
                "status",
                "",
            ),
    }


def check_appointment(
    patient_name,
    phone_number,
):

    # Live persistent appointments first.
    appointment = (
        find_dynamodb_appointment(
            patient_name,
            phone_number,
        )
        if dynamodb_enabled()
        else None
    )

    # Fall back to the original JSON dataset.
    if not appointment:

        appointment = find_json_appointment(
            patient_name,
            phone_number,
        )

    if not appointment:
        return {
            "success": False,
            "message": (
                "I couldn't find a confirmed "
                "appointment for that patient "
                "name and phone number."
            ),
        }

    # DynamoDB uses PascalCase attribute names,
    # while the original JSON dataset uses lowercase names.
    doctor_name = (
        appointment.get("DoctorName")
        or appointment.get("doctor_name")
        or ""
    )

    specialty = (
        appointment.get("Specialty")
        or appointment.get("specialty")
        or ""
    )

    appointment_date = (
        appointment.get("AppointmentDate")
        or appointment.get("date")
        or ""
    )

    appointment_time = (
        appointment.get("AppointmentTime")
        or appointment.get("time")
        or ""
    )

    appointment_id = (
        appointment.get("AppointmentId")
        or appointment.get("appointment_id")
        or ""
    )

    return {
        "success": True,
        "appointment": appointment,
        "message": (
            f"I found your appointment. "
            f"You are scheduled with "
            f"{doctor_name} "
            f"for {specialty} "
            f"on {appointment_date} "
            f"at {appointment_time}. "
            f"Your appointment ID is "
            f"{appointment_id}."
        ),
    }

def get_hospital_information(
    information_type
):

    info = normalize_text(
        information_type
    )

    information = {

        "timings": (
            "The hospital is open Monday "
            "to Sunday from 8:00 AM to "
            "8:00 PM. Emergency services "
            "are available 24 hours."
        ),

        "location": (
            "CareVoice Hospital is located "
            "at the hospital's main campus. "
            "Please contact reception for "
            "the exact address and directions."
        ),

        "services": (
            "The hospital provides general "
            "medicine, cardiology, dermatology, "
            "ophthalmology, orthopedics, "
            "pediatrics, gynecology, neurology, "
            "ENT, and dental services."
        ),

        "departments": (
            "Available departments include "
            "General Medicine, Cardiology, "
            "Dermatology, Dentistry, "
            "Ophthalmology, Orthopedics, "
            "Pediatrics, Gynecology, "
            "Neurology, and ENT."
        ),

        "contact": (
            "Please contact the hospital "
            "reception for appointment and "
            "general information."
        ),

        "emergency": (
            "Emergency services are available "
            "24 hours a day. For a life-threatening "
            "emergency, contact your local emergency "
            "services immediately."
        ),
    }

    return information.get(
        info,
        (
            "I can provide hospital timings, "
            "location, services, departments, "
            "contact details, or emergency "
            "information."
        ),
    )


def handle_human_agent():

    return (
        "Your request to speak with a "
        "support representative has been "
        "received."
    )



