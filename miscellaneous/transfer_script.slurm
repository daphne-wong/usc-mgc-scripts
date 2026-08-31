#!/bin/bash
#SBATCH --account=tp_612_1653
#SBATCH --partition=largemem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=150G
#SBATCH --time=12:00:00

module purge
module load gcc/11.3.0
module load python/3.9.12
module load pigz/2.7
module load parallel/20220522

find /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial/ -name "*.tar.gz" | parallel -j4 rsync -avz --info=progress2 {} bigyambat@192.168.1.20:/Volumes/NGS_File_Transfer_Drive/

#rsync -avz --info=progress2 --parallel=4 /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial/Compressed_Craig_VisiumHD_20240814_Complete.tar.gz bigyambat@192.168.1.20:/Volumes/NGS_File_Transfer_Drive/


#tar -cvf - -C /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial Craig_VisiumHD_20240814 | pigz -p 64 > /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/spatial/Compressed_Craig_VisiumHD_20240814_Complete.tar.gz


#rync -avz --progress /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Backup_Experiments/KGP_Transfer /project/mkast_1066/BCL_Transfer

#cp -vru --reflink=auto /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Backup_Experiments/KGP_Transfer /project/mkast_1066/BCL_Transfer


