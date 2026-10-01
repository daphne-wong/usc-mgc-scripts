#!/bin/bash
# QC summary for cellranger multi (v10) runs: custom MultiQC report, rename web summaries, combine all samples metrics CSV.

# First-time setup:
# python -m pip install --force-reinstall --no-deps /project2/tp_612_1653/resources/qc_for_10x/custom_multiqc

# Run from the directory that contains the <run>/outs folders:
# bash qc_cellranger-multi.sh

set -euo pipefail
shopt -s nullglob

run_name=$(basename "$(dirname "$PWD")")
out_dir="$PWD/multiqc"
sample_dirs=( "$PWD"/*/outs/per_sample_outs/*/ )


if [ ${#sample_dirs[@]} -eq 0 ]; then
  echo "No */outs/per_sample_outs/*/ folders found in $PWD" >&2
  exit 1
fi
mkdir -p "$out_dir/web_summaries"


# 1. MultiQC report (-f: overwrite a previous report instead of adding _1 suffixes)
multiqc -f -m custom_cellranger_multi --title "$run_name" -o "$out_dir" "$PWD"/*/outs/per_sample_outs


# 2. Rename and copy web summaries and 3. combine metrics csv, in one pass over the samples
collated="$out_dir/${run_name}_allSamples_metrics_summary.csv"
: > "$collated"
for d in "${sample_dirs[@]}"; do
  d=${d%/}
  sample=$(basename "$d")
  run=$(basename "${d%%/outs/*}")
  # name files by sample; prefix the run folder when it differs (e.g. Flex runs with several samples)
  label=$sample
  if [ "$run" != "$sample" ]; then label="${run}_${sample}"; fi

  if [ -e "$d/web_summary.html" ]; then
    cp "$d/web_summary.html" "$out_dir/web_summaries/${label}_web_summary.html"
  fi

  if [ -e "$d/metrics_summary.csv" ]; then
    if [ ! -s "$collated" ]; then
      head -n1 "$d/metrics_summary.csv" | sed 's/^/Run,Sample,/' > "$collated"
    fi
    # '$a\' adds a final newline if a file lacks one, so rows from different files never merge
    tail -n +2 "$d/metrics_summary.csv" | sed -e "s|^|${run},${sample},|" -e '$a\' >> "$collated"
  fi
done

echo "MultiQC report:    $out_dir/multiqc_report.html"
echo "Web summaries:     $out_dir/web_summaries/ (${#sample_dirs[@]} samples)"
echo "Combined metrics:  $collated"