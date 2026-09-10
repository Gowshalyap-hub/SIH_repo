# Current State Baseline Dataset Card

- **Dataset type**: Cross-sectional current-state classification
- **Target**: `class1`
- **Class meaning**: 0 = Normal/Absent, 1 = Mastitis Present
- **Prediction horizon**: Current state / point-in-time
- **NOT**: 7–14 day forecasting

## Features
- Milk_Temperature, Milk_Conductivity, Milk_Yield

## Excluded
- SCC, pH (Laboratory diagnostic leakage)
- Cow_ID (Identifier)
- Day (Corrupt placeholder)
- Clotting (Visual clinical sign, not automated telemetry)

## Limitations
- No longitudinal timeline
- No sensor-to-cow mapping
- No 7–14 day target
- Clinical and milk Cow_IDs do not overlap
