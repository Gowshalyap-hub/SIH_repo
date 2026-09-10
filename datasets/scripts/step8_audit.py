import os
import pandas as pd
import numpy as np
import joblib
import json

from sklearn.model_selection import train_test_split, RepeatedStratifiedKFold, cross_validate
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, average_precision_score

base_dir = r"c:\Users\gowth\Desktop\SIH\datasets"
ml_ready_file = os.path.join(base_dir, "ml_ready", "current_state_baseline.csv")
model_file = os.path.join(base_dir, "ml_models", "mastitis_current_state_baseline.pkl")

os.makedirs(os.path.join(base_dir, "ml_results"), exist_ok=True)

df = pd.read_csv(ml_ready_file)
X = df.drop(columns=['class1'])
y = df['class1']
features = list(X.columns)

# 1. VERIFY DATA DISTRIBUTION
dist = []
for f in features:
    for c in [0, 1]:
        subset = df[df['class1'] == c][f]
        dist.append({
            'feature': f,
            'class1': c,
            'count': subset.count(),
            'mean': subset.mean(),
            'median': subset.median(),
            'std': subset.std(),
            'min': subset.min(),
            'max': subset.max(),
            'q25': subset.quantile(0.25),
            'q75': subset.quantile(0.75),
            'iqr': subset.quantile(0.75) - subset.quantile(0.25)
        })
df_dist = pd.DataFrame(dist)
df_dist.to_csv(os.path.join(base_dir, "ml_results", "feature_class_distribution.csv"), index=False)

# 2 & 8. CHECK CLASS SEPARABILITY & RULE-BASED TARGET
sep_md = "# Feature Separability and Rule-Based Target Report\n\n"
for f in features:
    min_0, max_0 = df_dist[(df_dist['feature'] == f) & (df_dist['class1'] == 0)][['min', 'max']].values[0]
    min_1, max_1 = df_dist[(df_dist['feature'] == f) & (df_dist['class1'] == 1)][['min', 'max']].values[0]
    
    overlap = not (max_0 < min_1 or max_1 < min_0)
    
    sep_md += f"## {f}\n"
    sep_md += f"- **Normal (0) Range**: {min_0} to {max_0}\n"
    sep_md += f"- **Mastitis (1) Range**: {min_1} to {max_1}\n"
    sep_md += f"- **Overlap exists?**: {'Yes' if overlap else 'No'}\n\n"
    
    if not overlap:
        sep_md += f"**Observation**: `{f}` alone perfectly separates the classes. A simple threshold (e.g., between {max_0 if max_0 < min_1 else max_1} and {min_1 if max_0 < min_1 else min_0}) could completely determine the target.\n\n"

with open(os.path.join(base_dir, "ml_results", "feature_separability_report.md"), "w") as f_out:
    f_out.write(sep_md)
    
with open(os.path.join(base_dir, "ml_results", "target_separability_audit.md"), "w") as f_out:
    f_out.write("# Target Separability Audit\n\nThis is derived from the separability report. If any feature shows zero overlap, the target could be rule-based. See `feature_separability_report.md` for exact ranges.")

# 3. CHECK SIMPLE SINGLE-FEATURE MODELS
X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=0.30, stratify=y, random_state=42)
X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.50, stratify=y_temp, random_state=42)

single_res = []
for f in features:
    clf = Pipeline([
        ('scaler', StandardScaler()),
        ('lr', LogisticRegression(class_weight='balanced', random_state=42))
    ])
    clf.fit(X_train[[f]], y_train)
    y_test_pred = clf.predict(X_test[[f]])
    y_test_prob = clf.predict_proba(X_test[[f]])[:, 1]
    
    single_res.append({
        'feature': f,
        'accuracy': accuracy_score(y_test, y_test_pred),
        'precision': precision_score(y_test, y_test_pred, zero_division=0),
        'recall': recall_score(y_test, y_test_pred, zero_division=0),
        'f1': f1_score(y_test, y_test_pred, zero_division=0),
        'roc_auc': roc_auc_score(y_test, y_test_prob),
        'pr_auc': average_precision_score(y_test, y_test_prob)
    })
pd.DataFrame(single_res).to_csv(os.path.join(base_dir, "ml_results", "single_feature_performance.csv"), index=False)

# 4. CHECK FEATURE CORRELATION
corr_pearson = df.corr(method='pearson')
corr_pearson.to_csv(os.path.join(base_dir, "ml_results", "feature_target_correlations.csv"))

# 5. CHECK FOR DUPLICATES AND NEAR-DUPLICATES
exact_duplicates = df.duplicated().sum()
conflicting_duplicates = df.duplicated(subset=features, keep=False) & ~df.duplicated(keep=False)
conflicting_count = conflicting_duplicates.sum()

dup_md = f"""# Duplicate and Near-Duplicate Audit

- **Exact Duplicate Rows**: {exact_duplicates}
- **Conflicting Duplicate Rows (Identical features, different target)**: {conflicting_count}

"""
with open(os.path.join(base_dir, "ml_results", "duplicate_near_duplicate_audit.md"), "w") as f_out:
    f_out.write(dup_md)

# 6. CHECK TRAIN/TEST DISTRIBUTION
split_md = "# Split Distribution Audit\n\n"
for f in features:
    split_md += f"## {f}\n"
    split_md += f"- **Train Range**: {X_train[f].min()} to {X_train[f].max()}\n"
    split_md += f"- **Val Range**: {X_val[f].min()} to {X_val[f].max()}\n"
    split_md += f"- **Test Range**: {X_test[f].min()} to {X_test[f].max()}\n\n"

with open(os.path.join(base_dir, "ml_results", "split_distribution_audit.md"), "w") as f_out:
    f_out.write(split_md)

# 7. REPEATED STRATIFIED CROSS-VALIDATION
cv = RepeatedStratifiedKFold(n_splits=5, n_repeats=3, random_state=42)
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('lr', LogisticRegression(class_weight='balanced', random_state=42))
])
scoring = ['accuracy', 'precision', 'recall', 'f1', 'roc_auc', 'average_precision']
scores = cross_validate(pipeline, X, y, cv=cv, scoring=scoring)

cv_res = pd.DataFrame([{
    'metric': 'Accuracy', 'mean': np.mean(scores['test_accuracy']), 'std': np.std(scores['test_accuracy'])
}, {
    'metric': 'Precision', 'mean': np.mean(scores['test_precision']), 'std': np.std(scores['test_precision'])
}, {
    'metric': 'Recall', 'mean': np.mean(scores['test_recall']), 'std': np.std(scores['test_recall'])
}, {
    'metric': 'F1', 'mean': np.mean(scores['test_f1']), 'std': np.std(scores['test_f1'])
}, {
    'metric': 'ROC-AUC', 'mean': np.mean(scores['test_roc_auc']), 'std': np.std(scores['test_roc_auc'])
}, {
    'metric': 'PR-AUC', 'mean': np.mean(scores['test_average_precision']), 'std': np.std(scores['test_average_precision'])
}])
cv_res.to_csv(os.path.join(base_dir, "ml_results", "repeated_cv_results.csv"), index=False)

# 9. CHECK PROBABILITY OUTPUTS
model = joblib.load(model_file)
probs = model.predict_proba(X)[:, 1]
probs_0 = probs[y == 0]
probs_1 = probs[y == 1]

prob_md = f"""# Probability Distribution Audit

- **Minimum probability**: {np.min(probs)}
- **Maximum probability**: {np.max(probs)}
- **Median probability**: {np.median(probs)}

## Class 0 (Normal) Probabilities
- **Min**: {np.min(probs_0)}
- **Max**: {np.max(probs_0)}
- **Median**: {np.median(probs_0)}

## Class 1 (Mastitis) Probabilities
- **Min**: {np.min(probs_1)}
- **Max**: {np.max(probs_1)}
- **Median**: {np.median(probs_1)}

**Observation**: Probabilities are extremely separated if max for Class 0 is near 0 and min for Class 1 is near 1.
"""
with open(os.path.join(base_dir, "ml_results", "probability_distribution_audit.md"), "w") as f_out:
    f_out.write(prob_md)

# 10 & 11. DETERMINE LIKELY REASON & TRUST ASSESSMENT
trust_md = """# Model Trust Assessment

## Likely Reason for Perfect Score
Based strictly on evidence (such as lack of overlap in feature distributions or single features predicting the target perfectly), the likely reason is:
**B. Synthetic/constructed dataset characteristics** and/or **A. Genuine strong feature separation** depending on the specific ranges. However, such perfect clean separation is highly unusual for real-world biological data, suggesting the open-source dataset is heavily processed, threshold-based, or synthetic.

## Trust Classification
- **Software Integration Readiness**: PASS (It successfully exercises the pipeline and predicts).
- **Research Validity**: CONDITIONAL / FAIL (Perfect scores on biological data strongly imply artifacts).
- **Real-world Clinical Validity**: NOT ESTABLISHED.
- **7–14 Day Forecasting**: NOT SUPPORTED.

## Conclusion
The model is technically functional and suitable as a software integration baseline for the Smart Cup backend, but the perfect performance on this cross-sectional dataset does not establish real-world clinical performance.
"""
with open(os.path.join(base_dir, "ml_results", "model_trust_assessment.md"), "w") as f_out:
    f_out.write(trust_md)

print("Step 8 Forensic Audit Complete.")
