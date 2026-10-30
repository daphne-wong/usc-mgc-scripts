#!/bin/bash
#SBATCH --job-name=shallow_nf_RNAseq
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8GB
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=


# ========== Config (edit this section per run) ==========

# (1) Change path to config file here:
# example: config_file="/project2/weisenbe_1344/MGC/RNA-Seq/Siletz_20250902/run1/params_RNAseq.cfg"
config_file=$(find . -type f -name "params_RNAseq.cfg" -print -quit)

if [[ -z "${config_file}" ]]; then
echo "ERROR: Could not find params_RNAseq.cfg" >&2
exit 1
fi


# (2) In the #SBATCH header section at the beginning of this file...
# (2a) add your email to --mail-user=[email] to be notified of the run status (START, END/COMPLETE, or FAIL)


# (3) All run settings (samplesheet, reference, shallow-seq options) are set in params_RNAseq.cfg


# (4) To run this script, run the next line in the terminal without the starting '#'
# sbatch nf_RNAseq_shallow.slurm




# ========== Script (do not edit this section) ==========

# Load required modules
module purge
module load gcc/13.3.0
module load python/3.9.21
module load openjdk/21.0.0_35
module load nextflow/23.10.1
module load apptainer/1.4.5

export CACHE_BASE="/project2/tp_612_1653/resources/nextflow/apptainer_cache_base"
export NXF_APPTAINER_CACHEDIR="${CACHE_BASE}/nf_cache"
export APPTAINER_CACHEDIR="${CACHE_BASE}/apptainer_cache"
export APPTAINER_TMPDIR="${CACHE_BASE}/apptainer_tmp"


# Source config file
source ${config_file}

# Defaults if not set in config
align_mode="${align_mode:-star_salmon}"
min_trimmed_reads="${min_trimmed_reads:-10000}"
min_mapped_reads="${min_mapped_reads:-5}"
trimmer="${trimmer:-fastp}"
keep_bams="${keep_bams:-false}"

# Check required paths
for v in SAMPLESHEET OUT_DIR REF_FA REF_GTF; do
    if [[ -z "${!v}" ]]; then echo "ERROR: ${v} is not set in ${config_file}" >&2; exit 1; fi
done


# Shallow-seq options: skip depth-dependent / low-value QC and outputs
shallow_args=(
    --skip_stringtie
    --skip_bigwig
    --skip_preseq
    --skip_dupradar
    --skip_qualimap
    --save_align_intermeds false
    --rseqc_modules "bam_stat,infer_experiment,read_distribution"
    --min_trimmed_reads ${min_trimmed_reads}
    --min_mapped_reads ${min_mapped_reads}
)

aligner_args=()
if [[ "${align_mode}" == "salmon_only" ]]; then
    shallow_args+=( --skip_alignment --pseudo_aligner salmon )
elif [[ "${align_mode}" == "star_salmon" ]]; then
    if [[ -n "${STAR_INDEX}" ]]; then
        aligner_args=( --star_index ${STAR_INDEX} )
    else
        echo "WARNING: STAR_INDEX not set; pipeline will build a new STAR index (slow, ~32GB+ RAM)" >&2
    fi
else
    echo "ERROR: align_mode must be 'star_salmon' or 'salmon_only'" >&2
    exit 1
fi


# Print run settings to log
echo "Config:            ${config_file}"
echo "Samplesheet:       ${SAMPLESHEET}"
echo "Output dir:        ${OUT_DIR}"
echo "Align mode:        ${align_mode}"
echo "Trimmer:           ${trimmer}"
echo "Min trimmed reads: ${min_trimmed_reads}"
echo "Min mapped (%):    ${min_mapped_reads}"


# Run nf-core RNAseq pipeline
nextflow run nf-core/rnaseq \
    -r 3.14.0 \
    -c /project2/tp_612_1653/resources/nextflow/config/nf_slurm_profile.config \
    --input ${SAMPLESHEET} \
    --outdir ${OUT_DIR} \
    --gtf ${REF_GTF} \
    --fasta ${REF_FA} \
    "${aligner_args[@]}" \
    --igenomes_ignore \
    --genome null \
    --trimmer ${trimmer} \
    "${shallow_args[@]}" \
    -profile slurm,apptainer \
    -resume
