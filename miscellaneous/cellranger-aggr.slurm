#!/bin/bash
#SBATCH --job-name=cellranger-aggr
#SBATCH --partition=main
#SBATCH --account=tp_612_1653
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64GB
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=


# cellranger aggr will normalize all samples by default.
# A lot of sample-specific information from cellranger-multi or other cellranger analyses is lost when running aggr

# Load modules
module load cellranger/9.0.1


# Set aggr run ID
aggr_id=""

# Point to csv file path
# To generate: 
# while IFS= read -r sample; do path=$(readlink -f /project2/tp_612_1653/Priceman_Saul/Priceman_20260827_LH00311_0207_A23N7YHLT3/run1/${sample}/outs/per_sample_outs/${sample}/count/sample_molecule_info.h5); echo ${sample},${path} >> /project2/tp_612_1653/Priceman_Saul/Priceman_20260827_LH00311_0207_A23N7YHLT3/run1/aggregated_sample_summaries/Priceman_20260827_aggr.csv ; done < /project2/tp_612_1653/Priceman_Saul/Priceman_20260827_LH00311_0207_A23N7YHLT3/samplesheet.csv
# Need to manually add header: sample_id,molecule_h5

aggr_csv=""


# Run cellranger aggr

cellranger aggr \
   --id ${aggr_id} \
   --csv ${aggr_csv} \
   --normalize no

