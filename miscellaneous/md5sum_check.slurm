#!/bin/bash
#SBATCH --account=weisenbe_1344
#SBATCH --partition=epyc-64
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=4:00:00

module purge
module load conda

find /project2/weisenbe_1344/MGC/singleCell/priceman_novaseq_transfer/GEX_TCR_202508_Priceman/BCLConvert/fastq/combined -type f -name "*.fastq.gz" -exec md5sum {} \;
