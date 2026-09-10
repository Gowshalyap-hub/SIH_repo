from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from contextlib import asynccontextmanager
from app.iot.mqtt import start_mqtt_client, stop_mqtt_client
from app.api.v1.iot import router as iot_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    mqtt_client = start_mqtt_client()
    yield
    # Shutdown
    stop_mqtt_client(mqtt_client)

app = FastAPI(
    title="SIH Mastitis Backend API",
    description="Backend API for Mastitis Early Risk Forecasting System",
    version="1.0.0",
    lifespan=lifespan
)

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.api.v1.endpoints import router as api_router
from app.api.v1.auth import router as auth_router

app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(api_router, prefix="/api/v1")
app.include_router(iot_router, prefix="/api/v1/iot", tags=["iot"])

@app.get("/")
def read_root():
    return {"message": "SIH Mastitis Backend API is running"}

from app.iot import mqtt

@app.get("/api/v1/mastitis/latest")
def get_latest_mqtt_prediction():
    if mqtt.latest_mqtt_prediction is None:
        return {"status": "waiting", "message": "Waiting for sensor data"}
    return mqtt.latest_mqtt_prediction
