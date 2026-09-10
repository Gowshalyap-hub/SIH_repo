# Model Comparison Report

## Best Validation Model
**LogisticRegression** was selected based on validation performance (prioritizing Recall and F1 for mastitis screening).

|    | model                | split      |   accuracy |   precision |   recall |       f1 |   roc_auc |   pr_auc |   tn |   fp |   fn |   tp |
|---:|:---------------------|:-----------|-----------:|------------:|---------:|---------:|----------:|---------:|-----:|-----:|-----:|-----:|
|  0 | LogisticRegression   | validation |   1        |           1 |     1    | 1        |  1        | 1        |   94 |    0 |    0 |   26 |
|  1 | LogisticRegression   | test       |   1        |           1 |     1    | 1        |  1        | 1        |   95 |    0 |    0 |   25 |
|  2 | RandomForest         | validation |   1        |           1 |     1    | 1        |  1        | 1        |   94 |    0 |    0 |   26 |
|  3 | RandomForest         | test       |   1        |           1 |     1    | 1        |  1        | 1        |   95 |    0 |    0 |   25 |
|  4 | HistGradientBoosting | validation |   1        |           1 |     1    | 1        |  1        | 1        |   94 |    0 |    0 |   26 |
|  5 | HistGradientBoosting | test       |   0.991667 |           1 |     0.96 | 0.979592 |  0.997474 | 0.987027 |   95 |    0 |    1 |   24 |