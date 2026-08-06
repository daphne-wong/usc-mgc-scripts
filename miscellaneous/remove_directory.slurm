#!/bin/bash
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=150G
#SBATCH --time=12:00:00

module purge
module load gcc/11.3.0
module load python/3.9.12

rm /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Project_compressed_directory.tar.gz
