#!/bin/bash

#SBATCH --account=tp_612_1653
#SBATCH --partition=main
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3:00:00

module purge
module load conda/24.3.0

BCL_PATH="/project2/weisenbe_1344/MGC/bcl-convert/for_helen/bcl"
SAMPLE_SHEET="/project2/weisenbe_1344/MGC/bcl-convert/for_helen/samplesheet_v2.csv"
OUTPUT_DIR="/project2/weisenbe_1344/MGC/bcl-convert/for_helen/fastqs"

/project2/weisenbe_1344/MGC/bcl-convert/bcl-convert-4.4.4/usr/bin/bcl-convert --bcl-input-directory=$BCL_PATH \
									      --output-directory=$OUTPUT_DIR \
									      --sample-sheet=$SAMPLE_SHEET 

echo "Download Completed"

