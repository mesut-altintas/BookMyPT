import jwt, time, json, os, textwrap
import urllib.request
from cryptography.hazmat.primitives.serialization import load_pem_private_key

key_id    = os.environ["ASC_KEY_ID"]
issuer_id = os.environ["ASC_ISSUER_ID"]
raw_key   = os.environ["ASC_PRIVATE_KEY"].strip()

# Secret is stored as raw base64 (no PEM headers) — wrap it properly
wrapped = "\n".join(textwrap.wrap(raw_key, 64))
private_key_str = f"-----BEGIN EC PRIVATE KEY-----\n{wrapped}\n-----END EC PRIVATE KEY-----\n"

try:
    private_key_obj = load_pem_private_key(private_key_str.encode(), password=None)
    print("Key loaded: OK")
except Exception as e:
    print(f"EC PRIVATE KEY failed: {e}")
    # Try PRIVATE KEY header (PKCS#8)
    private_key_str = f"-----BEGIN PRIVATE KEY-----\n{wrapped}\n-----END PRIVATE KEY-----\n"
    private_key_obj = load_pem_private_key(private_key_str.encode(), password=None)
    print("Key loaded (PKCS8): OK")

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

# 2. Certificates
print("\n=== CERTIFICATES ===")
url2 = "https://api.appstoreconnect.apple.com/v1/certificates?filter[certificateType]=IOS_DISTRIBUTION,DISTRIBUTION"
data2 = json.loads(urllib.request.urlopen(urllib.request.Request(url2, headers=headers)).read())
for cert in data2.get("data", []):
    a = cert["attributes"]
    print(f"  {a['certificateType']}: {a['displayName']} (exp: {str(a.get('expirationDate','?'))[:10]})")
