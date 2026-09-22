# Running `nf_RNA-seq` analysis #

The RNA-seq pipeline we run is from Nextflow: [nf-core/rnaseq v.3.14.0](https://nf-co.re/rnaseq/3.14.0/). This is NOT the latest version of the pipeline. 

It has A LOT of parameters and options, but the ones we use at the core are preset in the script provided. If changes need to be made, please consult the nf-core/rnaseq [parameters docs](https://nf-co.re/rnaseq/3.14.0/parameters/).

For any questions about usage, refer to the nf-core/rnaseq [usage docs](https://nf-co.re/rnaseq/3.14.0/docs/usage/).

----

## (0) Understanding the run files ##

| File | What it contains | Naming Convention |
|---|---|---|
| SLURM file | Runs the RNAseq command on HPC via Nextflow. Requires Apptainer/Singularity. | `nf_RNAseq.slurm` |
| Samplesheet | Names of each sample (according to fastq), paths to fastq_r1 and fastq_r2, and strandedness of sample. Auto-generated in step 3.| `samplesheet.csv` |
| Parameters CFG | Controls the parameter of the run | `params_RNAseq.cfg` |
| FASTQs | Sequencing output | `*.fastqs.gz` |

----

## (1) Set up the run directory ##

On CARC, navigate to the correct PI folder under the project directory and create 2 directories:
```
mkdir {project name}

cd {project name}

mkdir fastqs run1
```

## (2) Download FASTQ files from BaseSpace ##
For a full runthrough, see here: [Downloading files from BaseSpace]()
```
# Move into fastqs directory and copy script
cd fastqs
cp /project2/tp_612_1653/scripts_test/miscellaneous/basespace-script.slurm .


# Activate basespace
mamba init bash
source ~/.bashrc
mamba activate basespace-cli


# Re-authenticate if needed
bs whoami
bs auth --force


# Find correct project ID
bs list projects


# Download files with basespace-script.slurm
# bs download project -i {ID} -o . --extension=fastq.gz


# Extract fastqs from individual folders and move into parent fastq directory, then remove empty directories
find . -type f -name "*.fastq.gz" -exec mv {} . \;
find . -type d -empty -delete

```

## (3) Project-specific Prep ##

### 1. Create `samplesheet.csv` file ###
* Has a **VERY SPECIFIC FORMAT.** 
  * See: [nf-core/rnaseq full samplesheet example](https://nf-co.re/rnaseq/3.14.0/docs/usage/#full-samplesheet)
  * Example: [RNAseq samplesheet](../../experiments/TESTED-RNA-seq/EXAMPLE_samplesheet_RNAseq.csv)
```
# If you are in the run1 directory with same setup from Step 1

cd ../run1

{echo "sample,fastq_1,fastq_2,strandedness"
    for r1 in ../fastqs/*_L001_R1_001.fastq.gz; do
        sample=$(basename "$r1" _L001_R1_001.fastq.gz)
        r2="${r1/_L001_R1_001.fastq.gz/_L001_R2_001.fastq.gz}"
        echo "${sample},${r1},${r2},auto"
    done } > samplesheet.csv

#----------------------------------------------------------------------------------

# If the fastqs are in a different directory, paste path in fastq_dir'

cd ../run1
fastq_dir=""
{echo "sample,fastq_1,fastq_2,strandedness"
    for r1 in ${fastq_dir}/*_L001_R1_001.fastq.gz; do
        sample=$(basename "$r1" _L001_R1_001.fastq.gz)
        r2="${r1/_L001_R1_001.fastq.gz/_L001_R2_001.fastq.gz}"
        echo "${sample},${r1},${r2},auto"
    done } > samplesheet.csv
```
### 3. Copy over scripts and files ###
```
cp /project2/tp_612_1653/scripts_test/experiments/RNA-seq/*RNAseq* .
```

### 4. Replace ${FILE} variable in params_RNAseq.cfg with path to `samplesheet.csv`
```
# If you are unsure of the samplesheet.txt path, run this command in your run1/ directory and copy the output:

readlink -f samplesheet.csv
```

### 5. Run the SLURM script
```
# By default, SLURM will send an email to the one affiliated with your CARC account when the job either completes successfully, or fails.

sbatch nf-RNAseq.slurm
```