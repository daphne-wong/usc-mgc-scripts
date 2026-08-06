#!/bin/bash
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=150G
#SBATCH --time=16:00:00

module purge
module load gcc/12.3.0
module load lz4/1.9.4
module load pigz  


tar --use-compress-program=pigz -xvf Project_compressed_directory.tar.gz

