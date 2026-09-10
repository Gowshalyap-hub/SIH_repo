import paho.mqtt.client as mqtt
import json
import logging
from datetime import datetime

from app.core.config import settings
from app.db.database import SessionLocal
from app.services.iot_ingestion import (
    ingest_smart_cup_reading,
    ingest_collar_reading,
    ingest_temperature_reading,
)
from app.schemas.iot import (
    IoTSmartCupPayload,
    IoTCollarPayload,
    IoTThermometerPayload,
)
from app.models.ai import AIPrediction
from pydantic import ValidationError


logger = logging.getLogger(__name__)


# ============================================================
# MQTT STATE
# ============================================================

latest_mqtt_prediction = None

# ============================================================
# MQTT TOPICS
# ============================================================

SMART_CUP_TOPIC = "sih/smartcup/+/telemetry"
COLLAR_TOPIC = "sih/collar/+/telemetry"
TEMP_TOPIC = "sih/temperature/+/telemetry"

# Wokwi topics
WOKWI_SENSOR_DATA_TOPIC = "bovineMastitis/naren/sensorData"
WOKWI_START_TOPIC = "bovineMastitis/naren/start"


# ============================================================
# MQTT CONNECT CALLBACK
# ============================================================

def on_connect(client, userdata, flags, rc):
    """
    Called when the MQTT client connects to the broker.
    """

    if rc == 0:
        logger.info("Connected to MQTT Broker!")

        client.subscribe([
            (SMART_CUP_TOPIC, 0),
            (COLLAR_TOPIC, 0),
            (TEMP_TOPIC, 0),
            (settings.FINAL_MASTITIS_TOPIC, 0),
            (WOKWI_SENSOR_DATA_TOPIC, 0),
            (WOKWI_START_TOPIC, 0),
        ])

        logger.info("MQTT topics subscribed successfully.")

    else:
        logger.error(
            f"Failed to connect to MQTT Broker, return code {rc}"
        )


# ============================================================
# MQTT MESSAGE CALLBACK
# ============================================================

def on_message(client, userdata, msg):
    """
    Handles incoming MQTT messages.

    Supports:
    1. Standard JSON IoT payloads
    2. Wokwi non-JSON text payloads
    """

    topic = msg.topic

    # --------------------------------------------------------
    # WOKWI START TRIGGER
    # --------------------------------------------------------

    if topic == WOKWI_START_TOPIC:
        logger.info(
            "Received START trigger from Sampling Cup ESP32-1"
        )
        return

    db = SessionLocal()

    try:

        # ====================================================
        # WOKWI SENSOR DATA
        # ====================================================

        if topic == WOKWI_SENSOR_DATA_TOPIC:

            # Wokwi simulation sends non-JSON text.
            #
            # Example:
            #
            # Activity:HIGH|
            # Rumination:HIGH|
            # BodyTemp:38.5C|
            # Humidity:70%
            #
            # Or potentially:
            #
            # Cow ID:COW001|
            # Milk Temperature:37.5|
            # Milk pH:6.7|
            # Milk Weight:2.5|
            # Spectral Value:1234

            payload_str = msg.payload.decode(
                "utf-8",
                errors="ignore"
            ).strip()

            logger.info(
                f"Received Wokwi payload: {payload_str}"
            )

            # ------------------------------------------------
            # BASIC TEXT PARSING
            # ------------------------------------------------

            parsed = {}

            # Normalize common suffixes.
            normalized_payload = (
                payload_str
                .replace("C|", "|")
                .replace("%", "")
            )

            # First attempt: pipe-delimited format.
            parts = normalized_payload.split("|")

            for part in parts:

                part = part.strip()

                if ":" in part:

                    key, value = part.split(":", 1)

                    parsed[key.strip()] = value.strip()

            # ------------------------------------------------
            # NEWLINE FALLBACK
            # ------------------------------------------------

            if not parsed:

                lines = payload_str.splitlines()

                for line in lines:

                    line = line.strip()

                    if ":" in line:

                        key, value = line.split(":", 1)

                        parsed[key.strip()] = value.strip()

            logger.info(
                f"Parsed Wokwi data: {parsed}"
            )

            current_time = datetime.utcnow().isoformat()

            # =================================================
            # SMART CUP PARSING
            # =================================================

            has_smart_cup_data = any(
                key in parsed
                for key in [
                    "Milk Temperature",
                    "Milk Weight",
                    "Milk pH",
                    "Spectral Value",
                    "Cow ID",
                ]
            )

            if has_smart_cup_data:

                # ------------------------------------------------
                # Safe numeric conversion helpers
                # ------------------------------------------------

                def safe_float(value, default=0.0):

                    try:
                        return float(value)

                    except (TypeError, ValueError):

                        return default

                milk_temperature = safe_float(
                    parsed.get("Milk Temperature")
                )

                milk_weight = safe_float(
                    parsed.get("Milk Weight")
                )

                milk_ph = None

                if "Milk pH" in parsed:

                    milk_ph = safe_float(
                        parsed.get("Milk pH"),
                        default=0.0
                    )

                spectral_value = None

                if "Spectral Value" in parsed:

                    spectral_value = safe_float(
                        parsed.get("Spectral Value"),
                        default=0.0
                    )

                cow_id = parsed.get(
                    "Cow ID",
                    None
                )

                # ------------------------------------------------
                # IMPORTANT:
                # Wokwi Sampling Cup does NOT provide EC.
                #
                # Therefore we DO NOT fabricate conductivity.
                # ------------------------------------------------

                milk_conductivity = 0.0

                sc_payload = IoTSmartCupPayload(

                    smart_cup_id="WOKWI-SC-1",

                    # Session may be resolved by the
                    # ingestion/business logic.
                    session_id=None,

                    cow_id=cow_id,

                    milk_temperature=milk_temperature,

                    milk_conductivity=milk_conductivity,

                    milk_yield=milk_weight,

                    milk_ph=milk_ph,

                    spectral_f1=spectral_value,

                    timestamp=current_time,
                )

                ingest_smart_cup_reading(
                    db,
                    sc_payload
                )

                logger.info(
                    "Wokwi Smart Cup reading ingested successfully."
                )

            # =================================================
            # COLLAR PARSING
            # =================================================

            has_collar_data = any(
                key in parsed
                for key in [
                    "Activity",
                    "Rumination",
                    "BodyTemp",
                    "Humidity",
                ]
            )

            if has_collar_data:

                # ------------------------------------------------
                # Safe numeric conversion
                # ------------------------------------------------

                def safe_float(value, default=0.0):

                    try:
                        return float(value)

                    except (TypeError, ValueError):

                        return default

                rumination = safe_float(
                    parsed.get("Rumination")
                )

                humidity = None

                if "Humidity" in parsed:

                    humidity = safe_float(
                        parsed.get("Humidity")
                    )

                activity = parsed.get(
                    "Activity",
                    "normal"
                ).lower()

                col_payload = IoTCollarPayload(

                    collar_device_id="WOKWI-COL-1",

                    activity_level=activity,

                    acceleration_magnitude=None,

                    rumination_minutes=rumination,

                    # ------------------------------------------------
                    # Current exact Wokwi Collar code does not contain
                    # INMP441 microphone logic.
                    #
                    # Therefore no fake sound value.
                    # ------------------------------------------------

                    rumination_sound_level=None,

                    humidity=humidity,

                    timestamp=current_time,
                )

                ingest_collar_reading(
                    db,
                    col_payload
                )

                logger.info(
                    "Wokwi Collar reading ingested successfully."
                )

            # =================================================
            # BODY TEMPERATURE PARSING
            # =================================================

            if "BodyTemp" in parsed:

                try:

                    body_temperature = float(
                        parsed.get("BodyTemp")
                    )

                    temp_payload = IoTThermometerPayload(

                        device_id="WOKWI-COL-1",

                        temperature=body_temperature,

                        timestamp=current_time,
                    )

                    ingest_temperature_reading(
                        db,
                        temp_payload
                    )

                    logger.info(
                        "Wokwi body temperature reading ingested successfully."
                    )

                except (TypeError, ValueError):

                    logger.error(
                        "Invalid BodyTemp value received from Wokwi."
                    )

            # ------------------------------------------------
            # WOKWI MESSAGE PROCESSING COMPLETE
            # ------------------------------------------------

            return

        # ====================================================
        # STANDARD MQTT TOPICS
        # ====================================================

        try:

            payload_dict = json.loads(
                msg.payload.decode(
                    "utf-8",
                    errors="ignore"
                )
            )

        except json.JSONDecodeError:

            logger.error(
                f"Failed to decode JSON from topic: {topic}"
            )

            return

        # ====================================================
        # STANDARD SMART CUP
        # ====================================================

        if topic.startswith("sih/smartcup/"):

            data = IoTSmartCupPayload(
                **payload_dict
            )

            ingest_smart_cup_reading(
                db,
                data
            )

            logger.info(
                f"Ingested Smart Cup reading from {topic}"
            )

        # ====================================================
        # STANDARD COLLAR
        # ====================================================

        elif topic.startswith("sih/collar/"):

            data = IoTCollarPayload(
                **payload_dict
            )

            ingest_collar_reading(
                db,
                data
            )

            logger.info(
                f"Ingested Collar reading from {topic}"
            )

        # ====================================================
        # STANDARD TEMPERATURE
        # ====================================================

        elif topic.startswith("sih/temperature/"):

            data = IoTThermometerPayload(
                **payload_dict
            )

            ingest_temperature_reading(
                db,
                data
            )

            logger.info(
                f"Ingested Temperature reading from {topic}"
            )

        # ====================================================
        # WORK 3: FINAL MASTITIS EQUATION
        # ====================================================
        elif topic == settings.FINAL_MASTITIS_TOPIC:
            try:
                required_keys = ["cow_id", "temp", "cond", "yield"]
                missing_keys = [k for k in required_keys if k not in payload_dict]
                if missing_keys:
                    logger.error(f"Missing required keys {missing_keys} in payload: {payload_dict}")
                    return
                
                cow_id = str(payload_dict["cow_id"])
                temp = float(payload_dict["temp"])
                cond = float(payload_dict["cond"])
                milk_yield = float(payload_dict["yield"])
                
                # Normalize values
                temp_norm = max(0.0, min(1.0, (temp - 34) / (40 - 34)))
                cond_norm = max(0.0, min(1.0, (cond - 3) / (9 - 3)))
                yield_norm = max(0.0, min(1.0, (30 - milk_yield) / (30 - 4)))
                
                # Apply equation
                risk_score = (0.34 * temp_norm + 0.35 * cond_norm + 0.31 * yield_norm) * 100
                
                if risk_score < 40:
                    level = "LOW"
                elif risk_score < 60:
                    level = "MODERATE"
                else:
                    level = "HIGH"
                
                output = (
                    f"\n---\n"
                    f"COW: {cow_id}\n"
                    f"Temperature: {temp} °C\n"
                    f"Conductivity: {cond}\n"
                    f"Milk Yield: {milk_yield} L\n\n"
                    f"Risk Score: {risk_score:.2f}\n"
                    f"Risk Level: {level}\n"
                    f"----------------\n"
                )
                print(output)
                logger.info(f"Processed Mastitis Risk for {cow_id}: {level} ({risk_score:.2f})")
                
                global latest_mqtt_prediction
                latest_mqtt_prediction = {
                    "cow_id": cow_id,
                    "temp": temp,
                    "cond": cond,
                    "yield": milk_yield,
                    "risk_score": risk_score,
                    "risk_level": level,
                    "timestamp": datetime.utcnow().isoformat()
                }
                
                # Save to database
                db_session = SessionLocal()
                try:
                    features_used_json = json.dumps({
                        "temp": temp,
                        "cond": cond,
                        "yield": milk_yield,
                        "risk_level": level
                    })
                    
                    pred = AIPrediction(
                        cow_id=cow_id,
                        prediction_type="live_mqtt_reading",
                        predicted_class=2 if level == "HIGH" else 1 if level == "MODERATE" else 0,
                        mastitis_probability=risk_score,
                        model_name="work_2_equation",
                        features_used=features_used_json,
                        timestamp=datetime.utcnow()
                    )
                    db_session.add(pred)
                    db_session.commit()
                except Exception as db_e:
                    logger.error(f"Failed to save live prediction to database: {db_e}")
                finally:
                    db_session.close()
                
            except (ValueError, TypeError) as e:
                logger.error(f"Invalid numeric sensor values in {settings.FINAL_MASTITIS_TOPIC}: {e}")

    # ========================================================
    # ERROR HANDLING
    # ========================================================

    except ValidationError as e:

        logger.error(
            f"Schema validation error on {topic}: {e}"
        )

    except ValueError as e:

        logger.error(
            f"Business logic error on {topic}: {e}"
        )

    except Exception as e:

        logger.error(
            f"Unexpected error processing {topic}: {e}"
        )

    finally:

        db.close()


# ============================================================
# START MQTT CLIENT
# ============================================================

def start_mqtt_client():

    # --------------------------------------------------------
    # Paho MQTT 2.x compatibility
    #
    # VERSION1 keeps compatibility with the existing
    # on_connect(client, userdata, flags, rc) callback.
    # --------------------------------------------------------

    client = mqtt.Client(
        callback_api_version=mqtt.CallbackAPIVersion.VERSION1,
        client_id=settings.MQTT_CLIENT_ID,
    )

    # --------------------------------------------------------
    # Optional MQTT authentication
    # --------------------------------------------------------

    if (
        settings.MQTT_USERNAME
        and settings.MQTT_PASSWORD
    ):

        client.username_pw_set(
            settings.MQTT_USERNAME,
            settings.MQTT_PASSWORD
        )

    # --------------------------------------------------------
    # Register callbacks
    # --------------------------------------------------------

    client.on_connect = on_connect
    client.on_message = on_message

    # --------------------------------------------------------
    # Connect to broker
    # --------------------------------------------------------

    try:

        client.connect(
            settings.MQTT_BROKER_HOST,
            settings.MQTT_BROKER_PORT,
            60
        )

        client.loop_start()

        logger.info(
            "MQTT Client loop started. "
            f"Connecting to "
            f"{settings.MQTT_BROKER_HOST}:"
            f"{settings.MQTT_BROKER_PORT}"
        )

    except Exception as e:

        # MQTT broker availability should not prevent
        # the FastAPI application from starting.

        logger.warning(
            "MQTT architecture implemented, "
            f"broker unavailable locally: {e}"
        )

    return client


# ============================================================
# STOP MQTT CLIENT
# ============================================================

def stop_mqtt_client(client):

    if client:

        try:

            client.loop_stop()
            client.disconnect()

            logger.info(
                "MQTT client stopped successfully."
            )

        except Exception as e:

            logger.warning(
                f"Error while stopping MQTT client: {e}"
            )