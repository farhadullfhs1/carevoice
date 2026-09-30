import logging

from interaction_engine import (
    book_appointment,
    check_appointment,
    get_hospital_information,
    get_slot_value,
    handle_human_agent as process_human_agent,
)

from lex_response import response


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handle_book_appointment(invocation_source, intent_name, slots):

    logger.info("BookAppointment invocation source: %s", invocation_source)
    logger.info("BookAppointment slots: %s", slots)

    required_slots = [
        "PatientName",
        "Specialty",
        "AppointmentDate",
        "AppointmentTime",
        "PhoneNumber",
    ]

    if invocation_source == "DialogCodeHook":

        missing_slot = next(
            (
                name
                for name in required_slots
                if not get_slot_value(slots, name)
            ),
            None,
        )

        if missing_slot:
            return response(
                "Delegate",
                intent_name,
                slots,
            )

        result = book_appointment(
            get_slot_value(slots, "PatientName"),
            get_slot_value(slots, "Specialty"),
            get_slot_value(slots, "AppointmentDate"),
            get_slot_value(slots, "AppointmentTime"),
            get_slot_value(slots, "PhoneNumber"),
            persist=False,
        )

        if result["success"]:
            return response(
                "Delegate",
                intent_name,
                slots,
            )

        if result["reason"] == "TIME_UNAVAILABLE":

            alternatives = result.get("alternative_times", [])

            message = (
                f"{result['requested_time']} is not available with "
                f"{result['doctor']['name']} on {result['date']}. "
                f"The available times are: "
                f"{', '.join(alternatives)}. "
                f"Which time would you prefer?"
            )

            return response(
                "ElicitSlot",
                intent_name,
                slots,
                message_text=message,
                slot_to_elicit="AppointmentTime",
            )

        if result["reason"] == "NO_DATE_AVAILABILITY":

            dates = result.get("alternative_dates", [])

            message = (
                f"There are no available appointments with "
                f"{result['doctor']['name']} on {result['date']}. "
                f"The next available dates are: "
                f"{', '.join(dates)}. "
                f"Which date would you prefer?"
            )

            return response(
                "ElicitSlot",
                intent_name,
                slots,
                message_text=message,
                slot_to_elicit="AppointmentDate",
            )

        return response(
            "Close",
            intent_name,
            slots,
            message_text=result["message"],
            intent_state="Failed",
        )

    if invocation_source == "FulfillmentCodeHook":

        result = book_appointment(
            get_slot_value(slots, "PatientName"),
            get_slot_value(slots, "Specialty"),
            get_slot_value(slots, "AppointmentDate"),
            get_slot_value(slots, "AppointmentTime"),
            get_slot_value(slots, "PhoneNumber"),
            persist=True,
        )

        if result["success"]:

            appointment = result["appointment"]

            message = (
                f"Your appointment has been booked successfully. "
                f"Your appointment ID is {appointment['appointment_id']}. "
                f"You are scheduled with {appointment['doctor_name']} "
                f"for {appointment['specialty']} on "
                f"{appointment['date']} at {appointment['time']}."
            )

            return response(
                "Close",
                intent_name,
                slots,
                message_text=message,
                intent_state="Fulfilled",
            )

        return response(
            "Close",
            intent_name,
            slots,
            message_text=result["message"],
            intent_state="Failed",
        )

    return response(
        "Delegate",
        intent_name,
        slots,
    )


def handle_check_appointment(intent_name, slots):

    patient_name = get_slot_value(slots, "PatientName")
    phone_number = get_slot_value(slots, "PhoneNumber")

    if not patient_name or not phone_number:

        missing_slot = (
            "PatientName"
            if not patient_name
            else "PhoneNumber"
        )

        prompt = (
            "May I have the patient's name?"
            if missing_slot == "PatientName"
            else "What phone number is associated with the appointment?"
        )

        return response(
            "ElicitSlot",
            intent_name,
            slots,
            message_text=prompt,
            slot_to_elicit=missing_slot,
        )

    result = check_appointment(
        patient_name,
        phone_number,
    )

    return response(
        "Close",
        intent_name,
        slots,
        message_text=result["message"],
        intent_state="Fulfilled" if result["success"] else "Failed",
    )


def handle_hospital_information(intent_name, slots):

    information_type = get_slot_value(
        slots,
        "InformationType",
    )

    if not information_type:

        return response(
            "Delegate",
            intent_name,
            slots,
        )

    message = get_hospital_information(
        information_type
    )

    return response(
        "Close",
        intent_name,
        slots,
        message_text=message,
        intent_state="Fulfilled",
    )


def handle_human_agent(intent_name, slots):

    return response(
        "Close",
        intent_name,
        slots,
        message_text=process_human_agent(),
        intent_state="Fulfilled",
    )


def lambda_handler(event, context):

    logger.info("========== CAREVOICE LAMBDA ==========")
    logger.info("EVENT RECEIVED: %s", event)

    session_state = event.get(
        "sessionState",
        {},
    )

    intent = session_state.get(
        "intent",
        {},
    )

    intent_name = intent.get(
        "name",
        "FallbackIntent",
    )

    slots = intent.get(
        "slots"
    ) or {}

    invocation_source = event.get(
        "invocationSource",
        "DialogCodeHook",
    )

    logger.info(
        "INTENT: %s",
        intent_name,
    )

    logger.info(
        "SLOTS: %s",
        slots,
    )

    logger.info(
        "INVOCATION SOURCE: %s",
        invocation_source,
    )

    if intent_name == "BookAppointment":
        return handle_book_appointment(
            invocation_source,
            intent_name,
            slots,
        )

    if intent_name == "CheckAppointment":
        return handle_check_appointment(
            intent_name,
            slots,
        )

    if intent_name == "HospitalInformation":
        return handle_hospital_information(
            intent_name,
            slots,
        )

    if intent_name == "HumanAgent":
        return handle_human_agent(
            intent_name,
            slots,
        )

    if intent_name == "CareVoiceHelp":

        return response(
            "Close",
            intent_name,
            slots,
            message_text=(
                "Hello! I am CareVoice. I can help you "
                "book appointments, check appointments, "
                "provide hospital information, or connect "
                "you with a support representative."
            ),
            intent_state="Fulfilled",
        )

    if intent_name == "FallbackIntent":

        return response(
            "Close",
            intent_name,
            slots,
            message_text=(
                "I'm sorry, I didn't understand that. "
                "You can ask me to book an appointment, "
                "check an appointment, get hospital "
                "information, or speak with a representative."
            ),
            intent_state="Fulfilled",
        )

    return response(
        "Close",
        intent_name,
        slots,
        message_text=(
            "I'm sorry, I didn't understand that request."
        ),
        intent_state="Failed",
    )
