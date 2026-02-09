import pandas as pd
import numpy as np
import os
from scipy import stats

# =====================================================
# Load Data
# =====================================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
df = pd.read_csv(os.path.join(BASE_DIR, '..', 'output', 'NIPPV_analytic_dataset.csv'))

# Ensure NIPPV failure is coded as Yes/No
df['failure'] = df['failure'].map({1: "Yes", 0: "No"})

# =====================================================
# Variable Definitions
# =====================================================

continuous_vars = {
    "age_at_admission": "Age at Admission, years",
    "map": "MAP, mmHg",
    "pco2_after_NIPPV": "Initial pCO₂, mmHg",
    "ph_after_NIPPV": "Initial pH",
    "peep_set_after_NIPPV": "Initial PEEP, cmH₂O",
    "tidal_volume_obs_after_NIPPV": "Tidal Volume, mL",
    "heart_rate_after_NIPPV": "HR after NIPPV, bpm",
    "respiratory_rate_after_NIPPV": "RR after NIPPV, bpm",
    "fio2_after_NIPPV": "FiO₂ after NIPPV, %"
}

categorical_vars = {
    "female": "Female"
}

# =====================================================
# Helper Functions (SAME AS YOUR ORIGINAL)
# =====================================================

def summarize_continuous(subdf, var):
    if subdf[var].notna().sum() == 0:
        return "NA"
    return f"{subdf[var].mean():.1f} ± {subdf[var].std():.1f}"

def summarize_categorical(subdf, var):
    counts = subdf[var].value_counts(dropna=False)
    pct = subdf[var].value_counts(normalize=True, dropna=False) * 100
    return {lvl: f"{counts[lvl]} ({pct[lvl]:.1f}%)" for lvl in counts.index}

# =====================================================
# NEW: P-VALUE FUNCTIONS (Parametric Assumption)
# =====================================================

def pvalue_continuous_ttest(df, var):
    x = df[df['failure'] == "Yes"][var].dropna()
    y = df[df['failure'] == "No"][var].dropna()

    if len(x) < 2 or len(y) < 2:
        return "NA"

    p = stats.ttest_ind(x, y, equal_var=False)[1]
    return f"{p:.3f}"

def pvalue_categorical_chisq(df, var):
    tab = pd.crosstab(df[var], df['failure'])

    if tab.shape[0] < 2:
        return "NA"

    p = stats.chi2_contingency(tab)[1]
    return f"{p:.3f}"

# =====================================================
# BUILD TABLE 1 (ORIGINAL + P-VALUES)
# =====================================================

rows = []
rows.append(["Variable", "NIPPV Failure: Yes", "NIPPV Failure: No", "Total", "p-value"])

# ----- Continuous -----
for var, label in continuous_vars.items():
    rows.append([
        label,
        summarize_continuous(df[df['failure'] == "Yes"], var),
        summarize_continuous(df[df['failure'] == "No"], var),
        summarize_continuous(df, var),
        pvalue_continuous_ttest(df, var)
    ])

# ----- Categorical -----
for var, label in categorical_vars.items():
    rows.append([label, "", "", "", ""])
   
    levels = df[var].dropna().unique()
    for lvl in levels:
        yes_stats = summarize_categorical(df[df['failure'] == "Yes"], var).get(lvl, "0 (0%)")
        no_stats  = summarize_categorical(df[df['failure'] == "No"], var).get(lvl, "0 (0%)")
        total_stats = summarize_categorical(df, var).get(lvl, "0 (0%)")

        rows.append([
            f"    {lvl}",
            yes_stats,
            no_stats,
            total_stats,
            pvalue_categorical_chisq(df, var)
        ])

# =====================================================
# Display
# =====================================================

table1 = pd.DataFrame(rows[1:], columns=rows[0])

print("\nTable 1. Descriptive Characteristics of Study Population by NIPPV Failure Status\n")
print(table1.to_string(index=False))
table1.to_csv(os.path.join(BASE_DIR, '..', 'output_to_share', 'descriptive_characteristics.csv'), index = False)