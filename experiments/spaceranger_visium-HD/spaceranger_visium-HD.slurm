#!/bin/bash
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=36:00:00
#SBATCH --partition=epyc-64

module load spaceranger/3.1.2

source /project2/weisenbe_1344/MGC/spatial/Torres_VisiumHD_NovaSeq_20250729/run2/config_visium_hd_spaceranger_human_1.txt

SAMPLELINE=$(sed -n "$SLURM_ARRAY_TASK_ID"p $FILE)

SAMPLEID=$(echo $SAMPLELINE | cut -d, -f1)
SLIDEID=$(echo $SAMPLELINE | cut -d, -f2)
AREAID=$(echo $SAMPLELINE | cut -d, -f3)

CYTAIMAGE="${IMAGEDIR}/${SAMPLEID}_${SLIDEID}_${AREAID}.tif"
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
		   --probe-set=${PROBESET} \
		   --cytaimage=${CYTAIMAGE} \
 		   --image=${IMAGE} \
                   --slide=${SLIDEID} \
                   --area=${AREAID} \
		   --loupe-alignment=${ALIGN} \
 		   --create-bam=true \

#Space Ranger v3.0 and later requires the --create-bam argument to be set to true or false. Use false for MiSeq run to save time and space. Here, we set it to false to save disk space and computation time. BAM files can be useful for long term data archiving, troubleshooting (especially mapping), and other reasons.

#Space Ranger v3.0 and later no longer requires the --slide and --area options if these metadata can be obtained from the CytAssist image.
