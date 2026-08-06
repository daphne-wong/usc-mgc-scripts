#!/bin/bash
#SBATCH --job-name=cellranger-multi_pooled
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=


# NOTE: THIS IS `cellranger-multi_pooled`, used for samples which were pooled into different FASTQ files during sequencing.
# If your data is NOT POOLED, please use `cellranger-multi.slurm` instead.



# ========== Config (edit this section per run) ==========

# (1) Change path to config_cellranger.txt file here:
# example: config_file="/project2/weisenbe_1344/MGC/singleCell/Priceman_Novaseq_GEX_TCR_20250821/run1/config_cellranger-multi.txt"
config_file=

# (2) In the #SBATCH header section at the beginning of this file...
# (2a) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)

# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch cellranger-multi.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load cellranger/9.0.1


# Source config file
source ${config_csv}


# Get sample name from samplesheet
SAMPLE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)


# Run cellranger multi
cellranger multi --id=${SAMPLE} \
                 --csv=${MULTI_CSV} \
                 --localcores=${CORES} \
                 --localmem=${MEM} 