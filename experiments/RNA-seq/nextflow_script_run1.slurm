#!/bin/bash
#SBATCH --partition=main
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=48:00:00

module purge
module load gcc/13.3.0
module load python/3.9.21
module load openjdk/21.0.0_35
module load nextflow/23.10.1
module load apptainer

nextflow run nf-core/rnaseq \
    --input /project2/weisenbe_1344/MGC/RNA-Seq/Mancuso_Plate3_20250317/samplesheet.csv \
    --outdir /project2/weisenbe_1344/MGC/RNA-Seq/Mancuso_Plate3_20250317/run1 \
    --gtf /project2/weisenbe_1344/MGC/resources/singlecell/refdata-gex-GRCh38-2024-A/genes/genes.gtf.gz \
    --fasta /project2/weisenbe_1344/MGC/resources/singlecell/refdata-gex-GRCh38-2024-A/fasta/genome.fa \
    --igenomes_ignore \
    --genome null \
    --trimmer fastp \
    -profile slurm,apptainer \
    --save_align_intermeds \
    -resume
