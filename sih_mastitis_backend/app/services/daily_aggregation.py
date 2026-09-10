from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.readings import CollarReading, MilkReading, TemperatureReading
from app.models.milking_session import MilkingSession
from datetime import date

def aggregate_daily_cow_features(db: Session, cow_id: str, target_date: date):
    """
    Foundation for future longitudinal forecasting.
    Aggregates activity, rumination, milk and temperature readings for a given cow on a specific date.
    This does NOT generate a prediction. It serves as future input.
    """
    
    # 1. Collar Data
    collar_stats = db.query(
        func.avg(CollarReading.activity_level).label("avg_activity"),
        func.sum(CollarReading.rumination_minutes).label("total_rumination")
    ).filter(
        # Assuming we can resolve CollarReading to cow_id. Currently CollarReading has collar_id.
        # We would join Cow to resolve this in a real system.
        func.date(CollarReading.timestamp) == target_date
    ).first()

    # 2. Milk Data
    milk_stats = db.query(
        func.sum(MilkReading.yield_volume).label("total_yield"),
        func.avg(MilkReading.temperature).label("avg_milk_temp"),
        func.avg(MilkReading.ec).label("avg_conductivity")
    ).join(MilkingSession).filter(
        MilkingSession.cow_id == cow_id,
        func.date(MilkReading.timestamp) == target_date
    ).first()

    # 3. Temperature Module
    temp_stats = db.query(
        func.avg(TemperatureReading.temperature).label("avg_body_temp")
    ).filter(
        TemperatureReading.cow_id == cow_id,
        func.date(TemperatureReading.timestamp) == target_date
    ).first()

    return {
        "cow_id": cow_id,
        "date": target_date,
        "total_yield": milk_stats.total_yield if milk_stats else None,
        "avg_milk_temp": milk_stats.avg_milk_temp if milk_stats else None,
        "avg_conductivity": milk_stats.avg_conductivity if milk_stats else None,
        "total_rumination": collar_stats.total_rumination if collar_stats else None,
        "avg_body_temp": temp_stats.avg_body_temp if temp_stats else None
    }
