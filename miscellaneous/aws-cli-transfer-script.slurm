#!/bin/bash

#SBATCH --account=tp_612_1653
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3:00:00

module purge
module load conda

#If running for the first time, run the following commands to create and activate the conda environment
#mamba create -n awscli
#mamba activate awscli
#mamba install conda-forge::awscli


#Activating awscli conda environment
eval "$(conda shell.bash hook)"
conda activate awscli

#AWS S3 Bucket Sync
aws s3 sync s3://chlacpm/shared/private/bambat/NovaSeq_20250207/ /scratch1/bambat/mgc/projects/spatial/DechenLin_VisiumHD_20250207/fastqs

