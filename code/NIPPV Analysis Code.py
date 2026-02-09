import pandas as pd

import numpy as np

import os

import statsmodels.api as sm

import statsmodels.formula.api as smf

from scipy.stats import chi2_contingency, ttest_ind

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
nippv_data = pd.read_csv(os.path.join(BASE_DIR, '..', 'output', 'NIPPV_analytic_dataset.csv'))

 

# Define the list of predictors for univariate logistic regression

predictors = [

    'age_scale', 'female', 'pco2_scale', 'ph_scale', 'map',
    'rr_scale', 'hr_scale', 'fio2_high', 'peep_set_after_NIPPV', 'tidal_volume_obs_after_NIPPV'
]
 

# Initialize list to store univariate results

univariate_results = []

 

# Univariate logistic regression for each predictor

for predictor in predictors:

    try:

        # Define the formula for univariate logistic regression

        formula = f'failure ~ {predictor}'

       

        # Fit the logistic regression model

        model = smf.logit(formula=formula, data=nippv_data).fit(disp=0)

       

        # Get OR, p-value, and CI for the predictor

        odds_ratio = np.exp(model.params[1])

        p_value = model.pvalues[1]

        conf_int = model.conf_int()

        lower_ci = np.exp(conf_int[0][1])

        upper_ci = np.exp(conf_int[1][1])

       

        # Store the results

        univariate_results.append({

            'Variable': predictor,

            'Odds Ratio': odds_ratio,

            'P-Value': p_value,

            '95% CI Lower': lower_ci,

            '95% CI Upper': upper_ci

        })

       

    except Exception as e:

        print(f"Error processing variable {predictor}: {e}")

 

# Convert univariate results to DataFrame

univariate_results_df = pd.DataFrame(univariate_results)

 

# Display univariate results

print("Univariate Logistic Regression Results:")

print(univariate_results_df)

 

# Define the formula for the final multivariable model with specific interaction terms

final_formula = ('failure ~ age_scale + female + pco2_scale + ph_scale + map'

                 '+ rr_scale + hr_scale + fio2_high + peep_set_after_NIPPV'

                 '+ tidal_volume_obs_after_NIPPV + age_scale * ph_scale + pco2_scale * rr_scale')

# Fit the final multivariable logistic regression model

final_model = smf.logit(formula=final_formula, data=nippv_data).fit()

 

# Extract ORs, p-values, and CIs for multivariable model

multivariable_results = pd.DataFrame({

    'Variable': final_model.params.index,

    'Odds Ratio': np.exp(final_model.params.values),

    'P-Value': final_model.pvalues.values,

    '95% CI Lower': np.exp(final_model.conf_int()[0].values),

    '95% CI Upper': np.exp(final_model.conf_int()[1].values)

})

 

# Display multivariable results

print("\nMultivariable Logistic Regression Results:")

print(multivariable_results)

# =====================================================
# EXPORT RESULTS TO CSV 
# =====================================================

univariate_results_df.to_csv(os.path.join(BASE_DIR, '..', 'output_to_share', 'univariate_logistic_results_rush.csv'), index=False)

multivariable_results.to_csv(os.path.join(BASE_DIR, '..', 'output_to_share', 'multivariable_logistic_results_rush.csv'), index=False)
