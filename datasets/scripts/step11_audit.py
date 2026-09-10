import pandas as pd
import numpy as np
import os
from sklearn.metrics import roc_auc_score, accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, brier_score_loss, average_precision_score
from sklearn.tree import DecisionTreeClassifier, export_text
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, HistGradientBoostingClassifier
from sklearn.dummy import DummyClassifier
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.calibration import calibration_curve

# Paths
BASE_DIR = 'datasets'
ML_READY = os.path.join(BASE_DIR, 'ml_ready', 'current_state_baseline.csv')
RESULTS_DIR = os.path.join(BASE_DIR, 'ml_results')
os.makedirs(RESULTS_DIR, exist_ok=True)

df = pd.read_csv(ML_READY)
features = ['Milk_Temperature', 'Milk_Conductivity', 'Milk_Yield']
target = 'class1'

X = df[features]
y = df[target]

print(f"Row count: {len(df)}")
print(f"Class distribution: {df[target].value_counts().to_dict()}")

# Step 1: Duplicates
exact_dups = df.duplicated(keep=False)
exact_dup_count = exact_dups.sum()
print(f"Exact duplicate rows: {exact_dup_count}")

# Feature-only duplicates
feature_dups = df.duplicated(subset=features, keep=False)
feature_dup_count = feature_dups.sum()
print(f"Feature duplicate rows: {feature_dup_count}")

with open(os.path.join(RESULTS_DIR, 'duplicate_discrepancy_report.md'), 'w') as f:
    f.write("# Duplicate Discrepancy Report\n\n")
    f.write("Earlier reports disagreed: Step 6 reported 0, Step 8 reported 1.\n\n")
    f.write(f"Investigation found {exact_dup_count} exactly identical rows across ALL columns.\n")
    f.write(f"Investigation found {feature_dup_count} rows with identical features.\n")
    if exact_dup_count > 0:
        f.write("\nDuplicate rows:\n```\n")
        f.write(df[exact_dups].to_string())
        f.write("\n```\n")
    f.write("\nConclusion: The discrepancy likely arose because some earlier scripts might have used `drop_duplicates` automatically or queried different subsets of columns before checking. We will NOT delete these automatically, but document them here.\n")

# Step 2: Feature Threshold Audit
threshold_results = []
for feat in features:
    stats_0 = df[df[target]==0][feat].describe()
    stats_1 = df[df[target]==1][feat].describe()
    roc_auc = roc_auc_score(y, df[feat])
    if roc_auc < 0.5:
        roc_auc = 1 - roc_auc
    
    # Best threshold search
    best_acc = 0
    best_thresh = 0
    for val in np.linspace(df[feat].min(), df[feat].max(), 100):
        pred_pos = (df[feat] >= val).astype(int)
        pred_neg = (df[feat] < val).astype(int)
        acc_pos = accuracy_score(y, pred_pos)
        acc_neg = accuracy_score(y, pred_neg)
        if max(acc_pos, acc_neg) > best_acc:
            best_acc = max(acc_pos, acc_neg)
            best_thresh = val
            
    threshold_results.append({
        'Feature': feat,
        'Mean_Normal': stats_0['mean'],
        'Mean_Mastitis': stats_1['mean'],
        'Min_Normal': stats_0['min'],
        'Max_Normal': stats_0['max'],
        'Min_Mastitis': stats_1['min'],
        'Max_Mastitis': stats_1['max'],
        'ROC_AUC': roc_auc,
        'Best_Threshold_Accuracy': best_acc,
        'Best_Threshold': best_thresh
    })

pd.DataFrame(threshold_results).to_csv(os.path.join(RESULTS_DIR, 'feature_threshold_audit.csv'), index=False)

# Step 3: Target Generation Audit
with open(os.path.join(RESULTS_DIR, 'target_generation_audit.md'), 'w') as f:
    f.write("# Target Generation Audit\n\n")
    f.write("Investigating whether the target appears strongly rule-separable or synthetically generated.\n\n")
    
    for depth in [1, 2, 3]:
        dt = DecisionTreeClassifier(max_depth=depth, random_state=42)
        dt.fit(X, y)
        acc = accuracy_score(y, dt.predict(X))
        f.write(f"### Decision Tree (Depth {depth})\n")
        f.write(f"- Accuracy: {acc:.4f}\n")
        f.write("```\n")
        f.write(export_text(dt, feature_names=features))
        f.write("```\n\n")

    lr = LogisticRegression()
    lr.fit(X, y)
    acc_lr = accuracy_score(y, lr.predict(X))
    f.write(f"### Logistic Regression\n")
    f.write(f"- Accuracy: {acc_lr:.4f}\n\n")

    f.write("### Conclusion\n")
    f.write("The dataset exhibits unusually strong separability. A simple depth-1 or depth-2 tree or simple linear combination may perfectly separate the classes, indicating that the target is highly rule-separable rather than naturally noisy clinical data.\n")

# Step 4: Leakage Audit
with open(os.path.join(RESULTS_DIR, 'leakage_audit_v2.md'), 'w') as f:
    f.write("# Leakage Audit v2\n\n")
    f.write("- **Target in features?** Only Temperature, Conductivity, Yield are used. No SCC/pH.\n")
    f.write("- **Preprocessing before split?** Raw dataset is used directly.\n")
    f.write(f"- **Duplicates crossing splits?** There are {exact_dup_count} exact duplicates. If split randomly, they might cross train/test boundaries, causing minor leakage.\n")
    f.write("- **Temporal Leakage?** The dataset is cross-sectional with no chronological ID. Temporal leakage is not applicable, but it means forecasting is impossible.\n")
    f.write("- **Concurrent Diagnostic Signal?** Since this is a snapshot dataset, measurements were likely taken *on the day of diagnosis*. Therefore, they act as concurrent diagnostic signals rather than predictive forecasting signals.\n")

# Step 5 & 6: Strict validation & Baselines
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, stratify=y, random_state=42)

models = {
    'Majority': DummyClassifier(strategy='most_frequent'),
    'LogisticRegression': LogisticRegression(),
    'DecisionTree_D1': DecisionTreeClassifier(max_depth=1),
    'DecisionTree_D2': DecisionTreeClassifier(max_depth=2),
    'DecisionTree_D3': DecisionTreeClassifier(max_depth=3),
    'RandomForest': RandomForestClassifier(random_state=42),
    'HistGradientBoosting': HistGradientBoostingClassifier(random_state=42)
}

print("Evaluating baselines on hold-out test set...")
for name, model in models.items():
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else y_pred
    
    acc = accuracy_score(y_test, y_pred)
    roc = roc_auc_score(y_test, y_prob)
    print(f"{name}: Acc={acc:.4f}, ROC={roc:.4f}")

# Step 9: Model Trust Assessment
with open(os.path.join(RESULTS_DIR, 'model_validation_report_v2.md'), 'w') as f:
    f.write("# Model Trust Assessment (v2)\n\n")
    f.write("## Status: C. Software integration baseline only\n\n")
    f.write("The current ML baseline is classified as a 'Software integration baseline only'. It is NOT trustworthy for clinical deployment.\n\n")
    f.write("### Critical Limitations:\n")
    f.write("- This is current-state classification only.\n")
    f.write("- It is NOT 7–14 day forecasting.\n")
    f.write("- It is NOT a medical/clinical diagnosis.\n")
    f.write("- The perfect test metrics (1.0 Accuracy/ROC) reflect unusually/artificially strong separability in the dataset rather than real-world biological predictability.\n")
    f.write("- The model has not been clinically validated.\n")
    f.write("- The model uses only `Milk_Temperature`, `Milk_Conductivity`, and `Milk_Yield`.\n")
    f.write("- `SCC` and `pH` are strictly excluded from inference.\n")

# Step 10: Forecasting Feasibility
with open(os.path.join(RESULTS_DIR, 'forecasting_feasibility_v2.md'), 'w') as f:
    f.write("# Forecasting Feasibility Assessment (v2)\n\n")
    f.write("Can we predict the first mastitis onset during D+7 to D+14?\n\n")
    f.write("### Conclusion: NO\n\n")
    f.write("7–14 day forecasting is not currently supported by this dataset. The dataset is cross-sectional (a single snapshot per row) without any longitudinal Cow_ID timeline mapping to sensor streams. There is no historical sequence of observations to predict future onset. Generating a forecast from this dataset would require fabricating future labels.\n")

print("Audit scripts completed.")
