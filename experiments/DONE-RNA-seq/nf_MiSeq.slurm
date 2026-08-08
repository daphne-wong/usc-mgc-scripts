#!/bin/bash
#SBATCH --job-name=nf-MiSeq
#SBATCH --partition=epyc-64
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=4
#SBATCH --mem=128GB
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=


# ========== Config (edit this section per run) ==========

# (1) Change paths to config file here:
# example: config_file="/project2/weisenbe_1344/MGC/RNA-Seq/Siletz_20250902/run1/params_MiSeq.cfg"
config_file=


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch nf_MiSeq.slurm




# ========== Script (do not edit this section) ==========

# Load required modules
module purge
module load gcc/13.3.0
module load python/3.9.21
module load openjdk/21.0.0_35
module load nextflow/23.10.1
module load apptainer/1.4.2


# Source config files
OUTDIR=$(pwd)
source ${config_file}


# Run nf-core RNAseq pipeline
nextflow run nf-core/rnaseq \
    --input ${SAMPLESHEET} \
    --outdir ${OUT_DIR} \
    --gtf ${REF_GTF} \
    --fasta ${REF_FA} \
    --igenomes_ignore \
    --genome null \
    --trimmer ${trimmer} \
    --min_trimmed_reads ${min_trimmed_reads} \
    -profile slurm,apptainer \
    --save_align_intermeds \
