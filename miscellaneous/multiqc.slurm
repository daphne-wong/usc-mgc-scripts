#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32GB
#SBATCH --time=4:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=


# Load conda env with multiqc

# If first time:
# conda create -n multiqc bioconda::multiqc
# conda activate multiqc

# Load conda env
eval "$(mamba shell hook --shell bash)"
conda activate multiqc


# Set variables

MODULE="cellranger"
#MODULE="spaceranger"
file_list""             # list of paths to cellranger output dir (one sample dir per line)
title=""                # Title of the multiqc output
out_dir=""              # multiqc will create a directory named "${title}_multiqc_report_data" for the output



# Run multiqc command
multiqc \
   --module ${MODULE} \
   --outdir ${out_dir} \
   --file-list ${file_list} \
   --title ${title} \
   --verbose \