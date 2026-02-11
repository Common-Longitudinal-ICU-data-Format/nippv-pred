#\!/bin/bash
uv sync
uv run python code/01_wide_generator.py
uv run jupyter nbconvert --to notebook --execute code/02_study_cohort.ipynb
uv run python code/03_descriptive_characteristics.py
uv run python code/04_analysis_no_interaction.py
uv run python code/05_analysis_interaction.py
