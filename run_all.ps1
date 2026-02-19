#Requires -Version 5.1
<#
.SYNOPSIS
    Runs the full NIPPV-Pred analysis pipeline on Windows/PowerShell.
.DESCRIPTION
    PowerShell equivalent of run_all.sh. Executes all 13 pipeline steps
    using uv for dependency management and Jupyter notebook execution.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Navigate to repo root (directory containing this script)
Set-Location -Path $PSScriptRoot

$LogFile = "pipeline_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Invoke-Step {
    param(
        [string]$Message,
        [string[]]$Command
    )
    $Message | Tee-Object -Append -FilePath $LogFile
    & $Command[0] $Command[1..($Command.Length - 1)] 2>&1 |
        Tee-Object -Append -FilePath $LogFile
    if ($LASTEXITCODE -ne 0) {
        "ERROR: Command failed with exit code $LASTEXITCODE" |
            Tee-Object -Append -FilePath $LogFile
        exit $LASTEXITCODE
    }
}

"=== NIPPV-Pred Pipeline ===" | Tee-Object -FilePath $LogFile
"Started: $(Get-Date)" | Tee-Object -Append -FilePath $LogFile
"Working directory: $PSScriptRoot" | Tee-Object -Append -FilePath $LogFile
"" | Tee-Object -Append -FilePath $LogFile

Invoke-Step "[Step 0/13] Installing dependencies..." uv, sync

Invoke-Step "[Step 1/13] Generating wide dataset..." `
    uv, run, python, code/01_wide_generator.py

Invoke-Step "[Step 2/13] Identifying study cohort (no BMI)..." `
    uv, run, jupyter, nbconvert, --to, notebook, --execute, code/02_study_cohort.ipynb

Invoke-Step "[Step 3/13] Identifying study cohort (BMI)..." `
    uv, run, jupyter, nbconvert, --to, notebook, --execute, code/02_study_cohort_bmi.ipynb

Invoke-Step "[Step 4/13] Identifying study cohort (no BMI, final)..." `
    uv, run, jupyter, nbconvert, --to, notebook, --execute, code/03_study_cohort_no_bmi.ipynb

Invoke-Step "[Step 5/13] Computing descriptive characteristics (no BMI)..." `
    uv, run, python, code/03_descriptive_characteristics.py

Invoke-Step "[Step 6/13] Computing descriptive characteristics (BMI)..." `
    uv, run, python, code/04_descriptive_characteristics_bmi.py

Invoke-Step "[Step 7/13] Computing descriptive characteristics (no BMI, final)..." `
    uv, run, python, code/05_descriptive_characteristics_no_bmi.py

Invoke-Step "[Step 8/13] Running logistic regression, no interaction (no BMI)..." `
    uv, run, python, code/04_analysis_no_interaction.py

Invoke-Step "[Step 9/13] Running logistic regression, no interaction (BMI)..." `
    uv, run, python, code/06_analysis_no_interaction_bmi.py

Invoke-Step "[Step 10/13] Running logistic regression, no interaction (no BMI, final)..." `
    uv, run, python, code/07_analysis_no_interaction_no_bmi.py

Invoke-Step "[Step 11/13] Running logistic regression, with interaction (no BMI)..." `
    uv, run, python, code/05_analysis_interaction.py

Invoke-Step "[Step 12/13] Running logistic regression, with interaction (BMI)..." `
    uv, run, python, code/08_analysis_interaction_bmi.py

Invoke-Step "[Step 13/13] Running logistic regression, with interaction (no BMI, final)..." `
    uv, run, python, code/09_analysis_interaction_no_bmi.py

"" | Tee-Object -Append -FilePath $LogFile
"=== Pipeline completed successfully ===" | Tee-Object -Append -FilePath $LogFile
"Finished: $(Get-Date)" | Tee-Object -Append -FilePath $LogFile
"Results in: output_to_share/bmi/ and output_to_share/no_bmi/" |
    Tee-Object -Append -FilePath $LogFile
"Log saved to: $LogFile"
