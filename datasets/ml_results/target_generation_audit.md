# Target Generation Audit

Investigating whether the target appears strongly rule-separable or synthetically generated.

### Decision Tree (Depth 1)
- Accuracy: 0.9988
```
|--- Milk_Temperature <= 36.84
|   |--- class: 0
|--- Milk_Temperature >  36.84
|   |--- class: 1
```

### Decision Tree (Depth 2)
- Accuracy: 1.0000
```
|--- Milk_Temperature <= 36.84
|   |--- class: 0
|--- Milk_Temperature >  36.84
|   |--- Milk_Yield <= 19.50
|   |   |--- class: 1
|   |--- Milk_Yield >  19.50
|   |   |--- class: 0
```

### Decision Tree (Depth 3)
- Accuracy: 1.0000
```
|--- Milk_Temperature <= 36.84
|   |--- class: 0
|--- Milk_Temperature >  36.84
|   |--- Milk_Yield <= 19.50
|   |   |--- class: 1
|   |--- Milk_Yield >  19.50
|   |   |--- class: 0
```

### Logistic Regression
- Accuracy: 1.0000

### Conclusion
The dataset exhibits unusually strong separability. A simple depth-1 or depth-2 tree or simple linear combination may perfectly separate the classes, indicating that the target is highly rule-separable rather than naturally noisy clinical data.
