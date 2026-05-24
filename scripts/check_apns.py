import os, sys

raw_key = os.environ.get("ASC_PRIVATE_KEY", "")

# Debug key structure (no secret content printed)
print(f"Key length: {len(raw_key)}")
print(f"Has actual newlines: {'chr(10)' in raw_key or chr(10) in raw_key}")
print(f"Has literal backslash-n: {chr(92)+'n' in raw_key}")
print(f"Has BEGIN: {'BEGIN' in raw_key}")
print(f"Has EC PRIVATE: {'EC PRIVATE' in raw_key}")
print(f"Has PRIVATE KEY: {'PRIVATE KEY' in raw_key}")
print(f"Line count (split newline): {len(raw_key.splitlines())}")
print(f"Line count (split literal): {len(raw_key.split(chr(92)+'n'))}")

# Try to fix and load
from cryptography.hazmat.primitives.serialization import load_pem_private_key

for attempt, key_str in enumerate([
    raw_key,
    raw_key.replace("\\n", "\n"),
    raw_key.replace("\\n", "\n").strip(),
]):
    try:
        load_pem_private_key(key_str.encode(), password=None)
        print(f"\nAttempt {attempt}: SUCCESS")
        break
    except Exception as e:
        print(f"Attempt {attempt}: FAILED - {e}")
