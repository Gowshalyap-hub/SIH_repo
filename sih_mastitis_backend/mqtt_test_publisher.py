import time
import json
import paho.mqtt.client as mqtt

BROKER = "test.mosquitto.org"
PORT = 1883
TOPIC = "sih/mastitis/cow/data"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to test broker!")
    else:
        print("Failed to connect, return code", rc)

client = mqtt.Client()
client.on_connect = on_connect

# Connect to a public broker for dummy testing (or use local if set up)
# In this workspace the FastAPI backend's settings.MQTT_BROKER_HOST might be different.
# Let's import the actual settings to make sure we use the same broker.
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from app.core.config import settings

print(f"Connecting to {settings.MQTT_BROKER_HOST}:{settings.MQTT_BROKER_PORT}...")
client.connect(settings.MQTT_BROKER_HOST, settings.MQTT_BROKER_PORT, 60)

client.loop_start()
time.sleep(1) # wait for connection

test_cases = [
    {
        "description": "LOW RISK",
        "payload": {
            "cow_id": "COW-LOW",
            "temp": 35.5,
            "cond": 4.5,
            "yield": 22.0
        }
    },
    {
        "description": "MODERATE RISK",
        "payload": {
            "cow_id": "COW-MOD",
            "temp": 36.8,
            "cond": 6.0,
            "yield": 15.0
        }
    },
    {
        "description": "HIGH RISK",
        "payload": {
            "cow_id": "COW-HIGH",
            "temp": 39.0,
            "cond": 7.5,
            "yield": 6.0
        }
    }
]

for case in test_cases:
    print(f"\nPublishing {case['description']} data...")
    client.publish(TOPIC, json.dumps(case["payload"]))
    time.sleep(2) # Give server time to process and output

print("\nDone publishing test data.")
client.loop_stop()
client.disconnect()
