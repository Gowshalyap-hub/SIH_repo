# Leakage Audit v2

- **Target in features?** Only Temperature, Conductivity, Yield are used. No SCC/pH.
- **Preprocessing before split?** Raw dataset is used directly.
- **Duplicates crossing splits?** There are 2 exact duplicates. If split randomly, they might cross train/test boundaries, causing minor leakage.
- **Temporal Leakage?** The dataset is cross-sectional with no chronological ID. Temporal leakage is not applicable, but it means forecasting is impossible.
- **Concurrent Diagnostic Signal?** Since this is a snapshot dataset, measurements were likely taken *on the day of diagnosis*. Therefore, they act as concurrent diagnostic signals rather than predictive forecasting signals.
