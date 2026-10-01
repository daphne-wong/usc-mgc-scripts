#!/bin/sh

# If this is your first time running the custom MultiQC module for Spaceranger v3.1.2
# python -m pip install --force-reinstall --no-deps /project2/tp_612_1653/resources/qc_for_10x/custom_multiqc

# To run the script:
# sh ./qc_spaceranger-HD.sh

set -e

run_name=$(basename "$(dirname "$PWD")")
in_dir="$PWD/*/outs"

mkdir -p multiqc
cd multiqc || exit 1


# Run multiqc
multiqc -o . --title="${run_name}" ${in_dir}

# Make web_summaries folder
mkdir -p web_summaries

# Copy individual web_summaries to the folder
for f in ${in_dir}/web_summary.html; do
  [ -e "$f" ] || continue
  s=$(basename "$(dirname "$(dirname "$f")")")
  cp "$f" "web_summaries/${s}_web_summary.html"
done