import sys
from pathlib import Path

LAMBDA_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(LAMBDA_DIR))

from interaction_engine import (
    normalize_specialty,
    normalize_time,
    find_doctor_by_specialty,
    get_available_dates,
    get_available_slots,
    book_appointment,
)

def test_specialty_case_insensitive():
    for value in ["Dermatologist", "dermatologist", "DERMATOLOGIST", "DeRmAtOlOgIsT"]:
        assert normalize_specialty(value) == "dermatology"
    assert find_doctor_by_specialty("DERMATOLOGIST")["name"] == "Dr. Patel"
    print("PASS: specialty_case_insensitive")

def test_time_normalization():
    assert normalize_time("12 PM") == "12:00"
    assert normalize_time("12 pm") == "12:00"
    assert normalize_time("9:30 AM") == "09:30"
    assert normalize_time("3:30 pm") == "15:30"
    print("PASS: time_normalization")

# Use availability that actually exists in the current doctors.json.
DOCTOR = find_doctor_by_specialty("Dermatologist")
assert DOCTOR is not None, "Dermatologist doctor not found in doctors.json"

AVAILABLE_DATES = get_available_dates(DOCTOR)
assert AVAILABLE_DATES, "No Dermatologist availability found in doctors.json"

TEST_DATE = AVAILABLE_DATES[0]
AVAILABLE_SLOTS = get_available_slots(DOCTOR, TEST_DATE)
assert AVAILABLE_SLOTS, f"No slots found for Dermatologist on {TEST_DATE}"

AVAILABLE_TIME = normalize_time(AVAILABLE_SLOTS[0])

def test_available_time():
    result = book_appointment(
        "Farhadul",
        "Dermatologist",
        TEST_DATE,
        AVAILABLE_TIME,
        "9821643078",
    )
    assert result["success"] is True
    assert result["selected_time"] == AVAILABLE_TIME
    print(f"PASS: available_time ({TEST_DATE} {AVAILABLE_TIME})")

def test_unavailable_time():
    # Find a time that is definitely not in the doctor's available slots.
    candidate_times = ["00:00", "12:00", "23:59", "01:00", "22:00"]
    unavailable = next(
        (t for t in candidate_times if t not in [normalize_time(x) for x in AVAILABLE_SLOTS]),
        None,
    )
    assert unavailable is not None, "Could not create an unavailable test time"

    result = book_appointment(
        "Farhadul",
        "dermatologist",
        TEST_DATE,
        unavailable,
        "9821643078",
    )
    assert result["success"] is False
    assert result["reason"] == "TIME_UNAVAILABLE"
    assert result["alternative_times"]
    print(f"PASS: unavailable_time ({unavailable} -> alternatives provided)")

def test_unavailable_date():
    # Pick a date immediately after the last known date.
    from datetime import date, timedelta
    last_date = date.fromisoformat(AVAILABLE_DATES[-1])
    unavailable_date = (last_date + timedelta(days=1)).isoformat()

    result = book_appointment(
        "Farhadul",
        "DERMATOLOGIST",
        unavailable_date,
        AVAILABLE_TIME,
        "9821643078",
    )
    assert result["success"] is False
    assert result["reason"] in {"NO_DATE_AVAILABILITY", "NO_AVAILABILITY"}
    print(f"PASS: unavailable_date ({unavailable_date})")

def test_general_physician_alias():
    doctor = find_doctor_by_specialty("GENERAL PHYSICIAN")
    assert doctor is not None
    assert normalize_specialty("GENERAL PHYSICIAN") == "general medicine"
    print("PASS: specialty_alias (General Physician -> General Medicine)")

print("=============================================")
print(" CAREVOICE BUSINESS LOGIC TESTS")
print("=============================================")
print(f"Using Dermatologist test date: {TEST_DATE}")
print(f"Existing Dermatologist slots: {', '.join(normalize_time(x) or str(x) for x in AVAILABLE_SLOTS)}")
print("")

test_specialty_case_insensitive()
test_time_normalization()
test_available_time()
test_unavailable_time()
test_unavailable_date()
test_general_physician_alias()

print("")
print("CAREVOICE BUSINESS LOGIC TESTS PASSED: 6/6")
