from handler import lambda_handler


def lex_event(intent_name, slots):
    return {
        "sessionState": {
            "intent": {
                "name": intent_name,
                "slots": slots
            }
        },
        "invocationSource": "FulfillmentCodeHook"
    }


def slot(value):
    return {
        "value": {
            "originalValue": value,
            "interpretedValue": value,
            "resolvedValues": [value]
        }
    }


def test_help():
    event = lex_event(
        "CareVoiceHelp",
        {}
    )

    result = lambda_handler(event, None)

    assert result["sessionState"]["dialogAction"]["type"] == "Close"
    assert "CareVoice" in result["messages"][0]["content"]


def test_book_appointment():
    event = lex_event(
        "BookAppointment",
        {
            "PatientName": slot("Aisha Khan"),
            "Specialty": slot("Cardiology"),
            "AppointmentDate": slot("2026-09-30"),
            "AppointmentTime": slot("10:00"),
            "PhoneNumber": slot("+91-9000000001")
        }
    )

    result = lambda_handler(event, None)

    message = result["messages"][0]["content"]

    assert result["sessionState"]["intent"]["state"] == "Fulfilled"
    assert "Aisha Khan" in message
    assert "Dr. Sharma" in message


def test_check_appointment():
    event = lex_event(
        "CheckAppointment",
        {
            "PatientName": slot("Aisha Khan"),
            "PhoneNumber": slot("+91-9000000001")
        }
    )

    result = lambda_handler(event, None)

    message = result["messages"][0]["content"]

    assert result["sessionState"]["intent"]["state"] == "Fulfilled"
    assert "Dr. Sharma" in message
    assert "Cardiology" in message


def test_hospital_information():
    event = lex_event(
        "HospitalInformation",
        {
            "InformationType": slot("Timings")
        }
    )

    result = lambda_handler(event, None)

    message = result["messages"][0]["content"]

    assert result["sessionState"]["intent"]["state"] == "Fulfilled"
    assert "hospital" in message.lower()


def test_human_agent():
    event = lex_event(
        "HumanAgent",
        {}
    )

    result = lambda_handler(event, None)

    message = result["messages"][0]["content"]

    assert result["sessionState"]["intent"]["state"] == "Fulfilled"
    assert "support representative" in message


def test_unknown_intent():
    event = lex_event(
        "FallbackIntent",
        {}
    )

    result = lambda_handler(event, None)

    assert result["sessionState"]["dialogAction"]["type"] == "Close"


if __name__ == "__main__":
    tests = [
        test_help,
        test_book_appointment,
        test_check_appointment,
        test_hospital_information,
        test_human_agent,
        test_unknown_intent,
    ]

    passed = 0

    for test in tests:
        test()
        print(f"PASS: {test.__name__}")
        passed += 1

    print()
    print(f"CAREVOICE LOCAL TESTS PASSED: {passed}/{len(tests)}")
