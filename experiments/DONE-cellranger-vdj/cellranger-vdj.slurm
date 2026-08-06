#!/bin/bash
#SBATCH --job-name=cellranger-vdj
#SBATCH --partition=main
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

# (1) Change path to config_cellranger.txt file here:
# example: config_file="/project2/weisenbe_1344/MGC/singleCell/Priceman_TCR_Only_20250715/run1/config_cellranger_vdj_mouse.txt"
config_file=


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) change --array=1-4 to the number of samples in your samplesheet (wc -l samplesheet.txt)
# (2b) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch --array=[range] cellrange-vdj.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load cellranger/9.0.1

# Source config file
source ${config_file}

# Get sample name from samplesheet
SAMPLE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)

# Run cellranger vdj 
cellranger vdj --id=${SAMPLE} \
	            --reference=${REFER} \
               --fastqs=${FASTQS} \
               --sample=${SAMPLE} \
               --localcores=${CORES} \
               --localmem=${MEM} \

