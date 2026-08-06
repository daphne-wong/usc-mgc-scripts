#!/bin/bash
#SBATCH --partition=main
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=150G
#SBATCH --time=12:00:00

module purge
module load gcc/11.3.0
module load python/3.9.12
module load pigz/2.7


#cp /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/RNA-seq/Compressed_Mancuso_20240814_Complete_Directory.tar.gz /project/nmancuso_955/data/mrna/raw/


#tar -cvf - -C /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/RNA-seq Mancuso_20240814 | pigz -p 32 > /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/RNA-seq/Compressed_Mancuso_20240814_Complete_Directory.tar.gz


rsync -avz --progress /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/RNA-seq/Siletz_20240910_MiSeq/fastqs/*.fastq.gz /project/siletz_1386/PartekFlow_Projects/

#cp -vru --reflink=auto /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Backup_Experiments/KGP_Transfer /project/mkast_1066/BCL_Transfer


