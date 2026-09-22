# Running `cellranger multi` #

Because the `cellranger-multi` analysis covers many different data sets, there will be a lot of manual set up for these runs. It is important to understand how the run libraries were set up and whether the samples were singleplexed, multiplexed, or pooled, as that will determine the information needed.

----

## (0) Understanding the run files ##

| File | What it contains | Naming Convention |
|---|---|---|
| SLURM file | Runs the cellranger-multi command on HPC | `cellranger-multi.slurm` |
| Cellranger-multi config CSV | Information needed by cellranger-multi | `*_multi.csv` |
| Samplesheet | Names of each sample**, one per line | `samplesheet.txt` |
| Parameters CFG | Controls the parameter of the run | `params_cellranger-multi.cfg` |
| FASTQs | Sequencing output | `*.fastqs.gz` |

\** If multiplexed, the samples should correspond to the names fastq files.

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
cp /project2/tp_612_1653/scripts/miscellaneous/basespace-script.slurm .


# Activate basespace
mamba init bash
source ~/.bashrc
mamba activate basespace-cli


# Re-authenticate if needed
bs whoami
bs auth --force


# Find project ID
bs list projects


# Download files with basespace-script.slurm
# bs download project -i {ID} -o . --extension=fastq.gz


# Extract fastqs from individual folders and move into parent fastq directory, then remove empty directories
find . -type f -name "*.fastq.gz" -exec mv {} . \;
find . -type d -empty -delete

```

## (3) Project-specific Prep ##
### 1. Create `samplesheet.txt` file
```
cd ../run1

```

### 2. Create `*_multi.csv` files ###
* One file per sample
* Must be placed within `run1/csv_files` directory
* Has a **VERY SPECIFIC FORMAT.** 
  * See: [cellranger-multi examples](../cellranger-multi_examples/) 
  * See: https://www.10xgenomics.com/support/software/cell-ranger/latest/advanced/cr-multi-config-csv-opts

```
cd csv_files
```
### 3. Copy over scripts and files ###
```
cp /project2/tp_612_1653/scripts/experiments/cellranger-multi/* .
```

### 4. Replace ${FILE} variable in params_cellranger-multi.cfg with path to `samplesheet.txt`
```
# If you are unsure of the samplesheet.txt path, run this command in your run1/ directory:

readlink -f samplesheet.txt
```

### 5. Run the SLURM script
```
# By default, SLURM will send an email to the one affiliated with your CARC account when the job either completes successfully, or fails.


# If your run has `n` samples:

sbatch --array=[1-n] cellranger-multi.slurm
```