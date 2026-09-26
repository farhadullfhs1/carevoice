import json
import os
import sys

sys.path.insert(0, ".")

import handler


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
EVENT_FILE = os.path.join(BASE_DIR, "test_event.json")


with open(EVENT_FILE, "r", encoding="utf-8") as file:
    event = json.load(file)


response = handler.lambda_handler(event, None)

print("\nLambda response:")
print(json.dumps(response, indent=2))
