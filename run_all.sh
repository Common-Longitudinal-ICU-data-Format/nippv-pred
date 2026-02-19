#!/bin/bash
set -euo pipefail

# Navigate to repo root (directory containing this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG_FILE="pipeline_$(date +%Y%m%d_%H%M%S).log"

echo "=== NIPPV-Pred Pipeline ===" | tee "$LOG_FILE"
echo "Started: $(date)" | tee -a "$LOG_FILE"
echo "Working directory: $SCRIPT_DIR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "[Step 0/13] Installing dependencies..." | tee -a "$LOG_FILE"
uv sync 2>&1 | tee -a "$LOG_FILE"

echo "[Step 1/13] Generating wide dataset..." | tee -a "$LOG_FILE"
uv run python code/01_wide_generator.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 2/13] Identifying study cohort (no BMI)..." | tee -a "$LOG_FILE"
uv run jupyter nbconvert --to notebook --execute code/02_study_cohort.ipynb 2>&1 | tee -a "$LOG_FILE"

echo "[Step 3/13] Identifying study cohort (BMI)..." | tee -a "$LOG_FILE"
uv run jupyter nbconvert --to notebook --execute code/02_study_cohort_bmi.ipynb 2>&1 | tee -a "$LOG_FILE"

echo "[Step 4/13] Identifying study cohort (no BMI, final)..." | tee -a "$LOG_FILE"
uv run jupyter nbconvert --to notebook --execute code/03_study_cohort_no_bmi.ipynb 2>&1 | tee -a "$LOG_FILE"

echo "[Step 5/13] Computing descriptive characteristics (no BMI)..." | tee -a "$LOG_FILE"
uv run python code/03_descriptive_characteristics.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 6/13] Computing descriptive characteristics (BMI)..." | tee -a "$LOG_FILE"
uv run python code/04_descriptive_characteristics_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 7/13] Computing descriptive characteristics (no BMI, final)..." | tee -a "$LOG_FILE"
uv run python code/05_descriptive_characteristics_no_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 8/13] Running logistic regression, no interaction (no BMI)..." | tee -a "$LOG_FILE"
uv run python code/04_analysis_no_interaction.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 9/13] Running logistic regression, no interaction (BMI)..." | tee -a "$LOG_FILE"
uv run python code/06_analysis_no_interaction_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 10/13] Running logistic regression, no interaction (no BMI, final)..." | tee -a "$LOG_FILE"
uv run python code/07_analysis_no_interaction_no_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 11/13] Running logistic regression, with interaction (no BMI)..." | tee -a "$LOG_FILE"
uv run python code/05_analysis_interaction.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 12/13] Running logistic regression, with interaction (BMI)..." | tee -a "$LOG_FILE"
uv run python code/08_analysis_interaction_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 13/13] Running logistic regression, with interaction (no BMI, final)..." | tee -a "$LOG_FILE"
uv run python code/09_analysis_interaction_no_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "=== Pipeline completed successfully ===" | tee -a "$LOG_FILE"
echo "Finished: $(date)" | tee -a "$LOG_FILE"
echo "Results in: output_to_share/bmi/ and output_to_share/no_bmi/" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE"
