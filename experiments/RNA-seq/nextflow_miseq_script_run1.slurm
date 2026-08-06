#!/bin/bash
#SBATCH --partition=epyc-64
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=12:00:00

module purge
module load gcc/13.3.0
module load python/3.9.21
module load openjdk/21.0.0_35
module load nextflow/23.10.1
module load apptainer/1.4.2

nextflow run nf-core/rnaseq \
    --input /project2/weisenbe_1344/MGC/RNA-Seq/Siletz_20250902/samplesheet.csv \
    --outdir /project2/weisenbe_1344/MGC/RNA-Seq/Siletz_20250902/run1 \
    --gtf /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Resources/cellranger/refdata-gex-GRCh38-2024-A/genes/genes.gtf \
    --fasta /project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Resources/cellranger/refdata-gex-GRCh38-2024-A/fasta/genome.fa \
    --igenomes_ignore \
    --genome null \
    --trimmer fastp \
    --min_trimmed_reads 10 \
    -profile slurm,apptainer \
    --save_align_intermeds \
