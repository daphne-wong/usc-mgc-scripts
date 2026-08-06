#!/bin/bash
#SBATCH --job-name=cellranger-arc
#SBATCH --partition=epyc-64
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=8:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --array=1-4


# ========== Config (edit this section per run) ==========

# (1) Change path to config_cellranger-arc.txt file here:
# example: config_file=/path/to/run1/config_cellranger-arc-GEXonly.txt
config_file=


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) change --array=1-4 to the number of samples in your samplesheet (wc -l samplesheet.txt)
# (2b) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch --array=[range] cellranger-arc-GEXonly.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load gcc/11.3.0
module load cellranger/8.0.1


# Source config file
source ${config_file}


# Get sample name
SAMPLE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)


# Run cellranger count
cellranger count --id=${SAMPLE} \
                 --transcriptome=${REFER} \
                 --fastqs=${FASTQS} \
                 --sample=${SAMPLE} \
                 --localcores=${CORES} \
                 --localmem=${MEM} \
                 --create-bam false \
                 --chemistry=ARC-v1  # GEX data from multiome run