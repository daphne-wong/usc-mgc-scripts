#!/bin/bash
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64GB
#SBATCH --time=8:00:00

#module load intel/18.0.4
#module load bcl2fastq2/2.20.0.422

# Set the bcl2fastq path
export PATH=/project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Packages/bcl2fastq/bin:$PATH


/project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Packages/bcl2fastq --runfolder-dir /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/bcl2fastq/Fu-TongLiu_20250129/bcl --output-dir /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/bcl2fastq/Fu-TongLiu_20250129/fastqs --sample-sheet /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/bcl2fastq/Fu-TongLiu_20250129/SampleSheet.csv  --BarcodeMismatchesIndex1 3 --BarcodeMismatchesIndex2 3
