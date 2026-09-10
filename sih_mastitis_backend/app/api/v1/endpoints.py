from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from datetime import datetime, timedelta
import uuid

from app.db.database import get_db
from app.api.dependencies import get_current_user, require_role
from app.models.user import User
from app.models.farm import Farm
from app.models.cow import Cow
from app.models.milking_session import MilkingSession
from app.models.readings import MilkReading
from app.models.data_entry import LabRecord, ManualData
from app.models.ai import AIPrediction, Alert, Feedback
from app.models.smart_cup import SmartCup

from app.schemas.base import FarmResponse, CowResponse, CowCreate, FarmUpdate
from app.schemas.domain import (
    MilkingSessionCreate, MilkingSessionResponse, 
    LabRecordCreate, LabRecordResponse, 
    AIPredictionResponse, CurrentStatePredictionRequest, 
    MilkReadingCreate, MilkReadingResponse,
    ManualDataCreate, ManualDataResponse,
    FeedbackCreate, FeedbackResponse
)

router = APIRouter()

@router.get("/farms", response_model=List[FarmResponse])
def get_farms(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role == "FARMER":
        farms = db.query(Farm).filter(Farm.id == current_user.farm_id).all()
    else:
        farms = db.query(Farm).all()
    return farms

@router.put("/farms/{farm_id}", response_model=FarmResponse)
def update_farm(farm_id: int, farm_update: FarmUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role == "FARMER" and current_user.farm_id != farm_id:
        raise HTTPException(status_code=403, detail="Not authorized to edit this farm")
    
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
        
    if farm_update.name is not None: farm.name = farm_update.name
    if farm_update.location_lat is not None: farm.location_lat = farm_update.location_lat
    if farm_update.location_long is not None: farm.location_long = farm_update.location_long
    if farm_update.vet_name is not None: farm.vet_name = farm_update.vet_name
    if farm_update.vet_phone is not None: farm.vet_phone = farm_update.vet_phone
    if farm_update.vet_email is not None: farm.vet_email = farm_update.vet_email
    if farm_update.additional_details is not None: farm.additional_details = farm_update.additional_details
    
    db.commit()
    db.refresh(farm)
    return farm

@router.get("/farms/{farm_id}/cows", response_model=List[CowResponse])
def get_cows(farm_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    if current_user.role == "FARMER" and current_user.farm_id != farm_id:
        raise HTTPException(status_code=403, detail="Not authorized to access this farm")
    cows = db.query(Cow).filter(Cow.farm_id == farm_id).all()
    
    # Enrich with latest data efficiently
    result = []
    for cow in cows:
        # Get latest prediction for risk
        latest_pred = db.query(AIPrediction).filter(AIPrediction.cow_id == cow.id).order_by(AIPrediction.timestamp.desc()).first()
        risk_level = None
        last_updated = None
        if latest_pred:
            risk_level = "high" if latest_pred.predicted_class == 1 else "none"
            last_updated = latest_pred.timestamp
            
        # Get latest milk reading
        latest_milk = db.query(MilkReading).join(MilkingSession).filter(MilkingSession.cow_id == cow.id).order_by(MilkReading.timestamp.desc()).first()
        last_yield = None
        if latest_milk:
            last_yield = latest_milk.yield_volume
            if not last_updated or latest_milk.timestamp > last_updated:
                last_updated = latest_milk.timestamp
                
        cow_dict = {
            "id": cow.id,
            "rfid": cow.rfid,
            "breed": cow.breed,
            "dob": cow.dob,
            "farm_id": cow.farm_id,
            "collar_id": cow.collar_id,
            "current_risk_level": risk_level,
            "last_milk_yield": last_yield,
            "last_updated": last_updated
        }
        result.append(cow_dict)
        
    return result

@router.post("/cows", response_model=CowResponse)
def create_cow(cow: CowCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # Check if farm exists and auth
    farm = db.query(Farm).filter(Farm.id == current_user.farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
        
    db_cow = Cow(
        id=cow.id,
        rfid=cow.rfid,
        breed=cow.breed,
        dob=cow.dob,
        farm_id=current_user.farm_id
    )
    db.add(db_cow)
    db.commit()
    db.refresh(db_cow)
    return db_cow

@router.get("/cows/{cow_id}", response_model=CowResponse)
def get_cow(cow_id: str, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    cow = db.query(Cow).filter(Cow.id == cow_id).first()
    if not cow:
        raise HTTPException(status_code=404, detail="Cow not found")
    if current_user.role == "FARMER" and cow.farm_id != current_user.farm_id:
        raise HTTPException(status_code=403, detail="Not authorized to access this cow")
    return cow

@router.post("/sessions/start", response_model=MilkingSessionResponse)
def start_session(session_data: MilkingSessionCreate, db: Session = Depends(get_db)):
    # Ensure smart cup is active
    cup = db.query(SmartCup).filter(SmartCup.id == session_data.smart_cup_id).first()
    if not cup:
        cup = SmartCup(id=session_data.smart_cup_id, mac_address="UNKNOWN", status="active")
        db.add(cup)
        
    db_session = MilkingSession(
        id=session_data.id or str(uuid.uuid4()),
        cow_id=session_data.cow_id,
        smart_cup_id=session_data.smart_cup_id,
        start_time=session_data.start_time
    )
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    return db_session

@router.post("/sessions/{session_id}/readings", response_model=MilkReadingResponse)
def add_milk_reading(session_id: str, reading: MilkReadingCreate, db: Session = Depends(get_db)):
    db_reading = MilkReading(**reading.model_dump())
    db.add(db_reading)
    db.commit()
    db.refresh(db_reading)
    return db_reading

@router.post("/cows/{cow_id}/lab-records", response_model=LabRecordResponse)
def add_lab_record(cow_id: str, record: LabRecordCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_record = LabRecord(
        **record.model_dump(),
        recorded_by=current_user.id
    )
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record
    
@router.post("/cows/{cow_id}/manual-data", response_model=ManualDataResponse)
def add_manual_data(cow_id: str, data: ManualDataCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    cow = db.query(Cow).filter(Cow.id == cow_id).first()
    if not cow:
        raise HTTPException(status_code=404, detail="Cow not found")
    if current_user.role == "FARMER" and cow.farm_id != current_user.farm_id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    db_data = ManualData(
        cow_id=cow_id,
        type=data.type,
        notes=data.notes,
        recorded_by=current_user.id
    )
    db.add(db_data)
    db.commit()
    db.refresh(db_data)
    return db_data

from app.schemas.domain import ManualSensorReadingCreate
from app.models.collar import CollarDevice
@router.post("/cows/{cow_id}/manual-sensor-reading")
def add_manual_sensor_reading(cow_id: str, reading: ManualSensorReadingCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    cow = db.query(Cow).filter(Cow.id == cow_id).first()
    if not cow:
        raise HTTPException(status_code=404, detail="Cow not found")
    if current_user.role == "FARMER" and cow.farm_id != current_user.farm_id:
        raise HTTPException(status_code=403, detail="Not authorized")
        
    session_id = str(uuid.uuid4())
    
    notes_parts = []
    if reading.notes:
        notes_parts.append(reading.notes)
    if reading.udder_temperature is not None:
        notes_parts.append(f"Udder Temp: {reading.udder_temperature}°C")

    # Only save milk reading if relevant fields provided
    if reading.milk_temperature is not None or reading.milk_conductivity is not None or reading.milk_yield is not None:
        cup = db.query(SmartCup).filter(SmartCup.id == "MANUAL_CUP").first()
        if not cup:
            cup = SmartCup(id="MANUAL_CUP", mac_address="UNKNOWN", status="active")
            db.add(cup)
            db.commit()
        
        db_session = MilkingSession(
            id=session_id,
            cow_id=cow_id,
            smart_cup_id="MANUAL_CUP",
            start_time=datetime.utcnow()
        )
        db.add(db_session)
        db.commit()

        db_reading = MilkReading(
            session_id=session_id,
            yield_volume=reading.milk_yield or 0.0,
            ec=reading.milk_conductivity or 0.0,
            temperature=reading.milk_temperature or 0.0,
            timestamp=datetime.utcnow()
        )
        db.add(db_reading)
        
        # Trigger prediction from manual data
        from app.core.ai_service import ai_service
        try:
            result = ai_service.predict_current_state(
                temperature=reading.milk_temperature or 0.0,
                conductivity=reading.milk_conductivity or 0.0,
                yield_volume=reading.milk_yield or 0.0
            )
            import json
            features_json = json.dumps({
                "temp": reading.milk_temperature or 0.0,
                "cond": reading.milk_conductivity or 0.0,
                "yield": reading.milk_yield or 0.0,
                "risk_level": "HIGH" if result["mastitis_probability"] > 0.6 else "MODERATE" if result["mastitis_probability"] > 0.4 else "LOW"
            })
            pred = AIPrediction(
                cow_id=cow_id,
                prediction_type="manual_sensor_reading",
                predicted_class=result["predicted_class"],
                mastitis_probability=result["mastitis_probability"],
                model_name=result["model_name"],
                features_used=features_json,
                timestamp=datetime.utcnow()
            )
            db.add(pred)
            db.commit()
            
            if result["predicted_class"] == 1:
                alert = Alert(
                    cow_id=cow_id,
                    message=f"Mastitis detected (Probability: {result['mastitis_probability']:.2f}) from manual reading",
                    is_read=0
                )
                db.add(alert)
        except Exception as e:
            print(f"Warning: AI Prediction failed during manual entry: {e}")

    if reading.activity_level is not None or reading.body_temperature is not None:
        c_id = cow.collar_id
        if not c_id:
            c_id = f"MANUAL_COLLAR_{cow_id}"
            cow.collar_id = c_id
            cd = CollarDevice(id=c_id, mac_address="UNKNOWN", status="active")
            db.add(cd)
            db.commit()
            
        from app.models.readings import CollarReading
        c_reading = CollarReading(
            collar_id=c_id,
            activity_level=str(reading.activity_level) if reading.activity_level else "normal",
            rumination_minutes=0.0,
            body_temperature=reading.body_temperature or 0.0,
            timestamp=datetime.utcnow()
        )
        db.add(c_reading)

    if notes_parts:
        db_data = ManualData(
            cow_id=cow_id,
            type="Manual Sensor Reading",
            notes=" | ".join(notes_parts),
            recorded_by=current_user.id
        )
        db.add(db_data)

    db.commit()
    return {"status": "success", "message": "Manual readings logged successfully."}

@router.post("/cows/{cow_id}/prediction", response_model=AIPredictionResponse)
def get_prediction(cow_id: str, request: CurrentStatePredictionRequest, db: Session = Depends(get_db)):
    from app.core.ai_service import ai_service
    
    try:
        # Run inference
        result = ai_service.predict_current_state(
            temperature=request.milk_temperature,
            conductivity=request.milk_conductivity,
            yield_volume=request.milk_yield
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))




        
    # Save to database
    pred = AIPrediction(
        cow_id=cow_id,
        prediction_type=result["prediction_type"],
        predicted_class=result["predicted_class"],
        mastitis_probability=result["mastitis_probability"],
        model_name=result["model_name"],
        features_used=",".join(result["features_used"]),
        timestamp=datetime.utcnow()
    )
    db.add(pred)
    db.commit()
    db.refresh(pred)
    
    # Alert generation logic
    if result["predicted_class"] == 1:
        alert = Alert(
            cow_id=cow_id,
            message=f"Mastitis detected (Probability: {result['mastitis_probability']:.2f})",
            is_read=0
        )
        db.add(alert)
        db.commit()
    
    # Return response including the warning
    return {
        "id": pred.id,
        "cow_id": pred.cow_id,
        "prediction_type": pred.prediction_type,
        "predicted_class": pred.predicted_class,
        "mastitis_probability": pred.mastitis_probability,
        "model_name": pred.model_name,
        "features_used": result["features_used"],
        "warning": result["warning"],
        "timestamp": pred.timestamp
    }

@router.get("/cows/{cow_id}/prediction/latest", response_model=dict)
def get_latest_prediction(cow_id: str, db: Session = Depends(get_db)):
    pred = db.query(AIPrediction).filter(AIPrediction.cow_id == cow_id).order_by(AIPrediction.timestamp.desc()).first()
    if not pred:
        raise HTTPException(status_code=404, detail="No predictions found")
    import json
    features = {}
    try:
        if pred.features_used:
            features = json.loads(pred.features_used)
    except Exception:
        pass
        
    return {
        "id": pred.id,
        "cow_id": pred.cow_id,
        "prediction_type": pred.prediction_type,
        "predicted_class": pred.predicted_class,
        "mastitis_probability": pred.mastitis_probability,
        "model_name": pred.model_name,
        "temp": features.get("temp", 0.0),
        "cond": features.get("cond", 0.0),
        "yield": features.get("yield", 0.0),
        "risk_score": pred.mastitis_probability,
        "risk_level": features.get("risk_level", "UNKNOWN"),
        "timestamp": pred.timestamp.isoformat()
    }

@router.get("/cows/{cow_id}/history", response_model=list)
def get_cow_history(cow_id: str, db: Session = Depends(get_db)):
    import json
    # Combine milk readings, manual data, and live MQTT predictions for history timeline
    history = []
    
    milk_readings = db.query(MilkReading, MilkingSession).join(MilkingSession).filter(MilkingSession.cow_id == cow_id).all()
    for mr, ms in milk_readings:
        history.append({
            "type": "Milk Reading",
            "yield": mr.yield_volume,
            "ec": mr.ec,
            "temp": mr.temperature,
            "timestamp": mr.timestamp
        })
        
    manual_data = db.query(ManualData).filter(ManualData.cow_id == cow_id).all()
    for md in manual_data:
        history.append({
            "type": md.type,
            "notes": md.notes,
            "timestamp": md.timestamp
        })

    live_preds = db.query(AIPrediction).filter(
        AIPrediction.cow_id == cow_id,
        AIPrediction.prediction_type == "live_mqtt_reading"
    ).all()
    for p in live_preds:
        try:
            features = json.loads(p.features_used) if p.features_used else {}
            history.append({
                "type": "Live Data",
                "risk_score": p.mastitis_probability,
                "risk_level": features.get("risk_level", "UNKNOWN"),
                "temp": features.get("temp", 0.0),
                "cond": features.get("cond", 0.0),
                "yield": features.get("yield", 0.0),
                "timestamp": p.timestamp
            })
        except Exception:
            continue
        
    # Sort by timestamp descending
    history.sort(key=lambda x: x["timestamp"], reverse=True)
    return history

@router.get("/dashboard", response_model=dict)
def get_dashboard(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    farm_id = current_user.farm_id
    total_cattle = db.query(func.count(Cow.id)).filter(Cow.farm_id == farm_id).scalar() or 0
    # Current classification counts based on latest prediction for each cow
    subq = db.query(AIPrediction.cow_id, func.max(AIPrediction.timestamp).label("max_ts")).group_by(AIPrediction.cow_id).subquery()
    latest_preds = db.query(AIPrediction).join(subq, (AIPrediction.cow_id == subq.c.cow_id) & (AIPrediction.timestamp == subq.c.max_ts)).all()
    
    no_risk = 0
    high_risk = 0 # Since it's only 2 classes, 0 is no risk, 1 is high risk
    
    for p in latest_preds:
        # ensure it's for this farm
        cow = db.query(Cow).filter(Cow.id == p.cow_id).first()
        if cow and cow.farm_id == farm_id:
            if p.predicted_class == 0:
                no_risk += 1
            elif p.predicted_class == 1:
                high_risk += 1
                
    recent_alerts = db.query(Alert).join(Cow).filter(Cow.farm_id == farm_id).order_by(Alert.timestamp.desc()).limit(5).all()

    # Get milking stats for today
    today = datetime.utcnow().date()
    milked_today = db.query(func.count(func.distinct(MilkingSession.cow_id))).join(Cow).filter(Cow.farm_id == farm_id, func.date(MilkingSession.start_time) == today).scalar() or 0
    
    # Get lab tests for today
    lab_tests_today = db.query(func.count(LabRecord.id)).join(Cow).filter(Cow.farm_id == farm_id, func.date(LabRecord.timestamp) == today).scalar() or 0

    # Calculate milk trend
    yesterday = today - timedelta(days=1)
    milk_today = db.query(func.sum(MilkReading.yield_volume)).join(MilkingSession).join(Cow).filter(Cow.farm_id == farm_id, func.date(MilkReading.timestamp) == today).scalar() or 0.0
    milk_yesterday = db.query(func.sum(MilkReading.yield_volume)).join(MilkingSession).join(Cow).filter(Cow.farm_id == farm_id, func.date(MilkReading.timestamp) == yesterday).scalar() or 0.0
    
    trend_pct = 0.0
    if milk_yesterday > 0:
        trend_pct = ((milk_today - milk_yesterday) / milk_yesterday) * 100
        
    milk_trend_str = f"+{trend_pct:.1f}%" if trend_pct > 0 else f"{trend_pct:.1f}%"

    return {
        "total_cattle": total_cattle,
        "no_risk": no_risk,
        "low_risk": 0,
        "moderate_risk": 0,
        "high_risk": high_risk,
        "milked_today": milked_today,
        "lab_tests": lab_tests_today,
        "milk_trend": milk_trend_str,
        "recent_alerts": [{"id": a.id, "message": a.message} for a in recent_alerts],
        "financial_impact": "$0"
    }

@router.get("/alerts", response_model=list)
def get_alerts(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    farm_id = current_user.farm_id
    alerts = []
    
    # We can fetch cows for this farm, and then fetch high-risk predictions to create alerts
    cows = db.query(Cow).filter(Cow.farm_id == farm_id).all()
    cow_ids = [cow.id for cow in cows]
    
    if cow_ids:
        preds = db.query(AIPrediction).filter(AIPrediction.cow_id.in_(cow_ids), AIPrediction.predicted_class == 1).order_by(AIPrediction.timestamp.desc()).limit(50).all()
        for p in preds:
            severity = "high"
            if p.mastitis_probability < 0.8:
                severity = "moderate"
            alerts.append({
                "id": str(p.id),
                "type": "Health Alert",
                "message": p.warning or f"High mastitis risk detected for {p.cow_id}",
                "timestamp": p.timestamp.isoformat(),
                "severity": severity,
                "read": False,
                "cowId": p.cow_id,
            })
            
    return alerts

@router.get("/recommendations", response_model=list)
def get_recommendations(db: Session = Depends(get_db)):
    return [
        {"id": 1, "title": "Review recent milk measurements"},
        {"id": 2, "title": "Consult veterinarian for high risk cows"},
        {"id": 3, "title": "Review hygiene/milking practices"}
    ]

@router.post("/feedback", response_model=FeedbackResponse)
def submit_feedback(feedback: FeedbackCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_feedback = Feedback(
        prediction_id=feedback.prediction_id,
        user_id=current_user.id,
        accuracy_rating=feedback.accuracy_rating,
        actual_outcome=feedback.actual_outcome,
        comments=feedback.comments
    )
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return db_feedback

from typing import Optional

@router.get("/analytics/farm/{farm_id}")
def get_analytics(
    farm_id: str, 
    start_date: Optional[str] = None, 
    end_date: Optional[str] = None, 
    db: Session = Depends(get_db)
):
    # Retrieve cows for the farm
    cows = db.query(Cow).filter(Cow.farm_id == farm_id).all()
    cow_ids = [cow.id for cow in cows]
    
    if not cow_ids:
        return {
            "risk_distribution": {"High Risk": 0, "Moderate Risk": 0, "Low Risk": 0},
            "milk_averages": [],
            "avg_milk": 0.0,
            "alerts_this_week": 0
        }
        
    from datetime import datetime, timedelta
    from sqlalchemy import func
    
    if end_date:
        end_dt = datetime.fromisoformat(end_date.replace("Z", "+00:00")).replace(tzinfo=None)
    else:
        end_dt = datetime.utcnow()
        
    if start_date:
        start_dt = datetime.fromisoformat(start_date.replace("Z", "+00:00")).replace(tzinfo=None)
    else:
        start_dt = end_dt - timedelta(days=7)

    # 1. Risk Distribution (from AIPrediction)
    predictions = db.query(AIPrediction).filter(
        AIPrediction.cow_id.in_(cow_ids), 
        AIPrediction.timestamp >= start_dt, 
        AIPrediction.timestamp <= end_dt
    ).all()

    risk_dist = {"High Risk": 0, "Moderate Risk": 0, "Low Risk": 0}
    
    import json
    for pred in predictions:
        features = {}
        try:
            if pred.features_used:
                features = json.loads(pred.features_used)
        except Exception:
            pass
            
        risk_level = features.get("risk_level")
        if not risk_level:
            if pred.mastitis_probability > 60:
                risk_level = "HIGH"
            elif pred.mastitis_probability > 40:
                risk_level = "MODERATE"
            else:
                risk_level = "LOW"
                
        if risk_level == "HIGH":
            risk_dist["High Risk"] += 1
        elif risk_level == "MODERATE":
            risk_dist["Moderate Risk"] += 1
        else:
            risk_dist["Low Risk"] += 1
            
    # 2. Milk Production (Avg) & Trend (from MilkReading)
    milk_readings = db.query(MilkReading).join(MilkingSession).filter(
        MilkingSession.cow_id.in_(cow_ids),
        MilkReading.timestamp >= start_dt,
        MilkReading.timestamp <= end_dt
    ).all()

    total_yield = 0.0
    yield_count = len(milk_readings)
    
    from collections import defaultdict
    daily_milk_sums = defaultdict(float)
    daily_milk_counts = defaultdict(int)
    
    for mr in milk_readings:
        total_yield += mr.yield_volume
        day_str = mr.timestamp.strftime("%a")
        daily_milk_sums[day_str] += mr.yield_volume
        daily_milk_counts[day_str] += 1
        
    # ALSO extract yield from the live MQTT predictions for the new hardware flow
    for pred in predictions:
        if pred.prediction_type == "live_mqtt_reading" and pred.features_used:
            try:
                features = json.loads(pred.features_used)
                if "yield" in features:
                    y_val = float(features["yield"])
                    total_yield += y_val
                    day_str = pred.timestamp.strftime("%a")
                    daily_milk_sums[day_str] += y_val
                    daily_milk_counts[day_str] += 1
                    yield_count += 1
            except Exception:
                pass
        
    avg_milk = (total_yield / yield_count) if yield_count > 0 else 0.0
    
    # Generate ordered days for chart
    days_in_range = []
    curr = start_dt
    while curr <= end_dt:
        days_in_range.append(curr.strftime("%a"))
        curr += timedelta(days=1)
        
    days_ordered = list(dict.fromkeys(days_in_range))
    
    milk_averages = []
    for d in days_ordered:
        if daily_milk_counts[d] > 0:
            val = daily_milk_sums[d] / daily_milk_counts[d]
        else:
            val = 0.0
        # Chart expects val around 20 for full height, we can leave raw avg. The UI divides by 20.
        milk_averages.append({"day": d, "avg": val})
        
    if not milk_averages:
        milk_averages = [{"day": "N/A", "avg": 0.0}]

    # 3. Alerts This Week (from Alert table or AIPrediction where class == 1)
    alerts_count = db.query(AIPrediction).filter(
        AIPrediction.cow_id.in_(cow_ids),
        AIPrediction.predicted_class == 1,
        AIPrediction.timestamp >= start_dt,
        AIPrediction.timestamp <= end_dt
    ).count()

    return {
        "risk_distribution": risk_dist,
        "milk_averages": milk_averages,
        "avg_milk": avg_milk,
        "alerts_this_week": alerts_count
    }
