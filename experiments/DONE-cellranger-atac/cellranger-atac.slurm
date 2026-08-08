#!/bin/bash
#SBATCH --job-name=cellranger
#SBATCH --partition=oneweek
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100GB
#SBATCH --time=36:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --array=1-4




# ========== Config (edit this section per run) ==========

# (1) Change path to config_cellranger.txt file here:
# example: config_file="/project2/weisenbe_1344/MGC/multiome/Hans_Multiome_07142025/run1/params_cellranger-atac.cfg"
config_file=


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) change --array=1-4 to the number of samples in your samplesheet (wc -l samplesheet.txt)
# (2b) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch --array=[range] cellranger-atac.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load gcc/11.3.0
module load cellranger-atac/2.1.0

# Source config file
source ${config_file}

# Get sample name from samplesheet
SAMPLELINE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)
SAMPLEID=$(echo $SAMPLELINE | cut -d, -f1)
echo "sample: $SAMPLEID"

# Run cellranger-atac count
cellranger-atac count --id=${SAMPLEID} \
                      --reference=${REFER} \
                      --fastqs=${FASTQS} \
                      --sample=${SAMPLEID} \
                      --chemistry=ARC-v1 \
                      --localcores=${CORES} \
                      --localmem=${MEM}
