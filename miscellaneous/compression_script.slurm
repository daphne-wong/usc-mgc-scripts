#!/bin/bash
#SBATCH --account=tp_612_1653
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=150G
#SBATCH --time=12:00:00

module purge
module load gcc/13.3.0
module load intel-oneapi/2024.1.0
module load pigz/2.8

tar -cvf - -C /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial Craig_VisiumHD_20240814 | pigz -p 64 > /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial/Compressed_Craig_VisiumHD_20240814_Complete.tar.gz


#rync -avz --progress /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Backup_Experiments/KGP_Transfer /project/mkast_1066/BCL_Transfer

#cp -vru --reflink=auto /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Backup_Experiments/KGP_Transfer /project/mkast_1066/BCL_Transfer


