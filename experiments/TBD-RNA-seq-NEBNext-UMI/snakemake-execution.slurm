#!/bin/bash

#SBATCH --account=weisenbe_1344
#SBATCH --partition=epyc-64
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=24:00:00

module purge
module load legacy/CentOS7
module load conda/24.3.0

# Initializing mamba
mamba init bash
source ~/.bashrc

#If running for the first time, run the following commands to create and activate the conda environment
mamba env create -f rna_umi_environment.yml

#If environment is already initialized, run the following commmand
conda activate rnaseq_umi

#Unlocking snakemake in directory
snakemake --unlock

snakemake -s count_NEB_RNA1.smk \
          --configfile /project2/weisenbe_1344/MGC/RNA-Seq/El-Khoueiry_QingruFeng_Novaseq_20250724/run2/config.yaml \
          --use-conda \
          --latency-wait 60 \

echo "Run Completed"

