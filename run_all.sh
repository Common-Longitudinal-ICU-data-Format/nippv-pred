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

echo "[Step 0/9] Installing dependencies..." | tee -a "$LOG_FILE"
uv sync 2>&1 | tee -a "$LOG_FILE"

echo "[Step 1/9] Generating wide dataset..." | tee -a "$LOG_FILE"
uv run python code/01_wide_generator.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 2/9] Identifying study cohort..." | tee -a "$LOG_FILE"
uv run jupyter nbconvert --to notebook --execute code/02_study_cohort.ipynb 2>&1 | tee -a "$LOG_FILE"

echo "[Step 3/9] Identifying study cohort (BMI)..." | tee -a "$LOG_FILE"
uv run jupyter nbconvert --to notebook --execute code/02_study_cohort_bmi.ipynb 2>&1 | tee -a "$LOG_FILE"

echo "[Step 4/9] Computing descriptive characteristics..." | tee -a "$LOG_FILE"
uv run python code/03_descriptive_characteristics.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 5/9] Computing descriptive characteristics (BMI)..." | tee -a "$LOG_FILE"
uv run python code/03_descriptive_characteristics_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 6/9] Running logistic regression, no interaction..." | tee -a "$LOG_FILE"
uv run python code/04_analysis_no_interaction.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 7/9] Running logistic regression, no interaction (BMI)..." | tee -a "$LOG_FILE"
uv run python code/05_analysis_no_interaction_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 8/9] Running logistic regression, with interaction..." | tee -a "$LOG_FILE"
uv run python code/06_analysis_interaction.py 2>&1 | tee -a "$LOG_FILE"

echo "[Step 9/9] Running logistic regression, with interaction (BMI)..." | tee -a "$LOG_FILE"
uv run python code/07_analysis_interaction_bmi.py 2>&1 | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "=== Pipeline completed successfully ===" | tee -a "$LOG_FILE"
echo "Finished: $(date)" | tee -a "$LOG_FILE"
echo "Results in: output_to_share/bmi/" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE"
