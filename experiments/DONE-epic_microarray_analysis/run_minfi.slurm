#!/bin/bash
#SBATCH --job-name=epic_array_analysis
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64GB
#SBATCH --time=8:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=

# NOTE: if you are re-running a job in the same directory, please delete previous output directories. Otherwise it will fail.
# rm -r Processed_Data_Files QC_Reports

# ========== Config (edit this section per run) ==========

# (1) Define array type, genome annotation, and samplesheet (FULL) path

# EPICv2 -- "IlluminaHumanMethylationEPICv2" "20a1.hg38"
# EPICv1 -- IlluminaHumanMethylationEPIC" "ilm10b5.hg38"
# mm285 -- "IlluminaMouseMethylation" "12.v1.mm10"

# example: array="IlluminaHumanMethylationEPICv2"
# example: annotation="20a1.hg38"
# example: samplesheet="/path/to/Illumina-style/samplesheet"

array=
annotation=
samplesheet=



# (2) In the #SBATCH header section at the beginning of this file...
# (2a) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch epic_array_analysis.slurm





# ========== Script (do not edit this section) ==========


# Load modules
module purge
module load gcc/13.3.0
module load r/4.4.2

# Create output folders
mkdir -p ../Processed_Data_Files
mkdir -p ../QC_Reports


# Run the R Script
Rscript epic_analysis.R "${array}" "${annotation}" "${samplesheet}"
