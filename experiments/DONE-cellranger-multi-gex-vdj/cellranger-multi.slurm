#!/bin/bash
#SBATCH --job-name=cellranger-multi
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=12:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=
#SBATCH --array=1-4


# NOTE: If your data is pooled between different FASTQ files, cellranger multi CANNOT BE RUN AS AN ARRAY. 
# You must use a new script for each pool because the `multi_config.csv` files are unique to each one.
# For each pooled fastq pair, you must list the samples + probe barcode IDs found in that pool only in the `multi_config.csv` file.
# Please use `cellranger-multi_pooled.slurm` instead.



# ========== Config (edit this section per run) ==========

# (1) Change path to config file here:
# example: config_file="/project2/weisenbe_1344/MGC/singleCell/Priceman_Novaseq_GEX_TCR_20250821/run1/params_cellranger-multi.cfg"
config_file=


# (2) Create samplesheet formatting
# Change: reference genome path
# Library fastq_id and fastq_path (dir, not file)
# Each sample should have an entry for Gene Expression and VDJ.
# fastq_id should match file name

csv_path="./csv_files"
mkdir -p ${csv_path}

cat <<EOF > ${csv_path}/${SAMPLE}_multi.csv
[gene-expression]
reference,/project2/tp_612_1653/Priceman_Saul/ref/GRCh38_TAG72-CAR/mkref_GRCh38_TAG72-CAR
create-bam,true

[vdj]
reference,/project2/weisenbe_1344/MGC/resources/vdj/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.1.0

[libraries]
fastq_id,fastqs,feature_types
20260722_GEX_${SLURM_ARRAY_TASK_ID},/project2/tp_612_1653/Priceman_Saul/Priceman_20260827_LH00311_0207_A23N7YHLT3/fastqs,Gene Expression
20260722_TCR_${SLURM_ARRAY_TASK_ID},/project2/tp_612_1653/Priceman_Saul/Priceman_20260827_LH00311_0207_A23N7YHLT3/fastqs,VDJ-T

EOF


# (3) In the #SBATCH header section at the beginning of this file...
# (3a) change --array=1-4 to the number of samples in your samplesheet (wc -l samplesheet.txt)
# (3b) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (4) To run this script, run the next line in the terminal without the starting '#'
# sbatch --array=[range] cellranger-multi.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load cellranger/9.0.1

# Source config file
source ${config_file}

# Get sample name from samplesheet
SAMPLE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)


# Run cellranger multi
cellranger multi --id=${SAMPLE} \
                 --csv=${MULTI_CSV} \
                 --localcores=${CORES} \
                 --localmem=${MEM} 