import os

raw_key = os.environ.get("ASC_PRIVATE_KEY", "")
print(f"Length: {len(raw_key)}")
print(f"First 5 char codes: {[ord(c) for c in raw_key[:5]]}")
print(f"Last 5 char codes: {[ord(c) for c in raw_key[-5:]]}")
print(f"Has newline (10): {10 in [ord(c) for c in raw_key]}")
print(f"Has carriage return (13): {13 in [ord(c) for c in raw_key]}")
print(f"Has dash (45): {45 in [ord(c) for c in raw_key[:10]]}")
