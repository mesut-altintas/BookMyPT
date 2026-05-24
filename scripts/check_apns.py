import jwt, time, json, os, base64
import urllib.request
from cryptography.hazmat.primitives.serialization import load_pem_private_key

key_id    = os.environ["ASC_KEY_ID"]
issuer_id = os.environ["ASC_ISSUER_ID"]
raw_key   = os.environ["ASC_PRIVATE_KEY"].strip()

# Secret is base64-encoded PEM — decode it first
pem_content = base64.b64decode(raw_key).decode("utf-8")
print(f"Decoded PEM starts with: {pem_content[:30].strip()}")

private_key_obj = load_pem_private_key(pem_content.encode(), password=None)
print("Key loaded: OK")

now = int(time.time())
payload = {"iss": issuer_id, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
token = jwt.encode(payload, private_key_obj, algorithm="ES256", headers={"kid": key_id})
headers = {"Authorization": f"Bearer {token}"}

# 1. Bundle ID capabilities
url = "https://api.appstoreconnect.apple.com/v1/bundleIds?filter[identifier]=com.bookmypt&include=bundleIdCapabilities&fields[bundleIdCapabilities]=capabilityType"
data = json.loads(urllib.request.urlopen(urllib.request.Request(url, headers=headers)).read())

print("\n=== BUNDLE ID ===")
for item in data.get("data", []):
    a = item["attributes"]
    print(f"  {a['name']} | {a['identifier']} | {a['platform']}")

print("\n=== CAPABILITIES ===")
caps = []
for inc in data.get("included", []):
    cap = inc["attributes"]["capabilityType"]
    caps.append(cap)
    print(f"  - {cap}")

if "PUSH_NOTIFICATIONS" in caps:
    print("\n[RESULT] PUSH_NOTIFICATIONS: AKTIF")
else:
    print("\n[RESULT] PUSH_NOTIFICATIONS: EKSIK!")
