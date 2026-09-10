# Dataset Relationships

1. **Cow to Sensor (Device)**: 
   - `Cow_ID` (Clinical) <--> `Device_ID` (Folder names C01-C16, T01-T14). 
   - A mapping table is required if `C01` != `Cow_ID`.

2. **Temporal Alignment**:
   - Sensor data (`datetime`) must be aggregated to daily (`Day`) to match `Clinical_Mastitis_cows_version2`.
