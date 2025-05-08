#!/usr/bin/env bash
# run_analysis.sh

set -euo pipefail

# Create image dir if missing
mkdir -p img

# Render HTML report
Rscript -e "rmarkdown::render('Stock_Market_Analysis.Rmd')"

# Optionally convert to PDF
# pandoc Stock_Market_Analysis.html -o Stock_Market_Analysis.pdf --pdf-engine=xelatex

echo "Analysis complete. See Stock_Market_Analysis.html and img/*.png"
