def response(
    action,
    intent_name=None,
    slots=None,
    message_text=None,
    slot_to_elicit=None,
    intent_state=None
):
    session_state = {
        "dialogAction": {
            "type": action
        }
    }

    if action == "ElicitSlot":
        session_state["dialogAction"]["slotToElicit"] = slot_to_elicit

    if intent_name is not None:
        session_state["intent"] = {
            "name": intent_name,
            "slots": slots or {}
        }

        if intent_state is not None:
            session_state["intent"]["state"] = intent_state

    result = {
        "sessionState": session_state
    }

    if message_text:
        result["messages"] = [
            {
                "contentType": "PlainText",
                "content": message_text
            }
        ]

    return result
