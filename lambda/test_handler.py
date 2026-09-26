import json
import sys

sys.path.insert(0, ".")

import handler


with open("test_event.json", "r", encoding="utf-8") as file:
    event = json.load(file)


response = handler.lambda_handler(event, None)

print("\nLambda response:")
print(json.dumps(response, indent=2))
