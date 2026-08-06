#!/bin/bash
#SBATCH --job-name=cellranger-mkref
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=4:00:00


# NOTE: This is to build a custom reference fasta file for Cellranger, for a non-standard species of interest or modified reference genome.
# Required: (1) genome fasta file in a `.fa` format, (2) GTF file in a `.gtf` or `.gtf.gz` format


# ========== Config (edit this section per run) ==========

# (1) Name the output reference genome directory
# example: ref_genome_name="refdata-gex-GRCm39-2024-A_with_PSCACAR_PSMACAR_TAG72CAR"
ref_genome_name=



# (2) Change path to fasta and gtf file here:
# example: fa_file="/project2/weisenbe_1344/MGC/resources/tcr/priceman_fasta_gtf/fasta/genome.fa"
fa_file=

# example: gtf_file="/project2/weisenbe_1344/MGC/resources/tcr/priceman_fasta_gtf/genes/genes.gtf.gz"
gtf_file=


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch cellranger-mkref.slurm






# ========== Script (do not edit this section) ==========

# Load required modules
module load cellranger/9.0.1


# Run cellranger mkref
cellranger mkref --genome=${ref_genome_name} \
    --fasta= ${fa_file} \
    --genes= ${gtf_file} \