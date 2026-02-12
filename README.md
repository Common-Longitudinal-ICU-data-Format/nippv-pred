# NIPPV Prediction

## Objective

To identify predictors of noninvasive positive pressure ventilation (NIPPV) failure in patients with acute hypercapnic respiratory failure using the Common Longitudinal ICU data Format (CLIF).

## Outcome Definition

**NIPPV Failure** is defined as:

  1) Death **or**
  2) Escalation to invasive mechanical ventilation

within **48 hours** of NIPPV initiation.

## Predictors 

Unless otherwise specified, physiologic predictors are defined as the **median value 1-12 hours following NIPPV initiation**. Continuous variables are scaled to improve interpretability of regression coefficients.
  1) **age_scale**
     - Age scaled per 10-year increase
  3) **female**
     - Female vs. Male (reference); binary (0/1)
  5) **pco2_scale**
     - Median pCO2 (arterial or venous) scaled per 10 mmHg increase
  7) **ph_scale**
     - Median pH (arterial or venous) scaled per 0.1 unit increase
  9) **map_scale**
      - Median mean arterial pressure (MAP) scaled per 10 mmHg increase
  11) **rr_scale**
      - Median respiratory rate scaled per 5 bpm increase
  13) **hr_scale**
      - Median heart rate scaled per 10 bpm increase
  15) **fio2_high**
      - Median FiO2 > 0.4 vs. <= 0.4 (reference); binary (0/1)
  17) **peep_scale**
      - Median positive end-experatory pressure (PEEP) scaled per 2 cmH2O increase
  19) **tidal_volume_scale**
      - Median Tidal volume scaled per 100 mL increase
  21) **age_scale * ph_scale**
      - Age-acidosis interaction
  23) **pco2_scale * rr_scale**
      - Hypercapnia-respiratory rate interaction.

## Cohort Identification

Inclusion Criteria:
  1) NIPPV initiation within **6 hours** of the first recorded vital sign
  2) Median pCO2 (arterial or venous) >= 45 mmHg prior to NIPPV initiation
  3) Median pH (arterial or venous) <= 7.35 prior to NIPPV initiation
     
Exclusion Criteria:
  1) Median FiO2 >= 0.6 prior to NIPPV initiation

## Output

The following csv files are generated: 
  1) **consort.csv**
     - cohort counts used to construct the CONSORT diagram
  2) **descriptive_caractersitics.csv**
     - Baseline characteristics stratified by NIPPV failure
     - Continuous variables compared using *t-tests*
     - Categorical variables compared using *chi-squared tests*
  3) **multivariable_logistic_results_Interaction.csv**
      - Multivariable logistic regression results including interaction terms
  4) **multivariable_logistic_results_NoInteraction.csv**
      - Multivariable logistic regression results without interaction terms
  5) **univariate_logistic_resuts_Interaction.csv**
      - Univariate logistic regression results including interaction terms
  6) **univariate_logistic_results_NoInteraction.csv**
      - Univariate logistic regression results without interaction terms
