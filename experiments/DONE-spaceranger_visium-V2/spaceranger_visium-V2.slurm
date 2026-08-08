#!/bin/bash
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=36:00:00
#SBATCH --partition=main


#!/bin/bash
#SBATCH --job-name=cellranger
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=8:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --array=1-4


# ========== Config (edit this section per run) ==========

# (1) Change path to config file here:
# example: config_file="/project2/weisenbe_1344/MGC/spatial/Kelly_Visium_v2_20250815/run1/params_visium-V2.cfg"
config_file=


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) change --array=1-4 to the number of samples in your samplesheet (wc -l samplesheet.txt)
# (2b) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) To run this script, run the next line in the terminal without the starting '#'
# sbatch --array=[range] spaceranger_visium-V2.slurm







# ========== Script (do not edit this section) ==========

# Load required modules
module load spaceranger/3.1.2

# Source config file
source ${config_file}

# Extract sample information from samplesheet
SAMPLELINE=$(sed -n "${SLURM_ARRAY_TASK_ID}"p ${SAMPLESHEET})

SAMPLEID=$(echo ${SAMPLELINE} | cut -d, -f1)
SLIDEID=$(echo ${SAMPLELINE} | cut -d, -f2)
AREAID=$(echo ${SAMPLELINE} | cut -d, -f3)

CYTAIMAGE="${IMAGEDIR}/${SAMPLEID}_${SLIDEID}-${AREAID}.tif"
IMAGE="${IMAGEDIR}/${SAMPLEID}.tif"
ALIGN="${IMAGEDIR}/${SLIDEID}-${AREAID}.json"

#spaceranger count --id=${SAMPLEID} \
#                  --transcriptome=${REFER} \
#                  --probe-set=${PROBESET} \
#                  --fastqs=${FASTQS} \
#                  --sample=${SAMPLEID} \
#                  --cytaimage=${CYTAIMAGE} \
#                  --image=${IMAGE} \
#                  --slide=${SLIDEID} \
#                  --area=${AREAID} \
#                  --loupe-alignment=${ALIGN} \
#                  --localcores=${CORES} \
#                  --localmem=${MEM}

 spaceranger count --id=${SAMPLEID} \
                   --sample=${SAMPLEID} \
		   			 --transcriptome=${REFER} \
						 --fastqs=${FASTQS} \
						 --cytaimage=${CYTAIMAGE} \
						 --image=${IMAGE} \
						 --loupe-alignment=${ALIGN} \
						 --create-bam=true \
						 --unknown-slide=visium-2 \
						 --probe-set=${PROBESET} \
#                  --slide=${SLIDEID} \
#                  --area=${AREAID} \

#Space Ranger v3.0 and later requires the --create-bam argument to be set to true or false. Use false for MiSeq run to save time and space. 
#Here, we set it to false to save disk space and computation time. BAM files can be useful for long term data archiving, troubleshooting (especially mapping), and other reasons.

#Space Ranger v3.0 and later no longer requires the --slide and --area options if these metadata can be obtained from the CytAssist image.
