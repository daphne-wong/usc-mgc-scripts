#!/bin/bash
#SBATCH --account=tp_612_1653
#SBATCH --partition=epyc-64
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=3:00:00

module purge
module load legacy/CentOS7
module load conda/24.3.0

# Initializing mamba
mamba init bash
source ~/.bashrc

#If running for the first time, run the following commands to create and activate the conda environment
#mamba create -n basespace-cli
#mamba activate basespace-cli
#mamba install hcc::basespace-cli

#If environment is already initialized, run the following commmand
mamba activate basespace-cli


#If changing Basespace account or initializing Basespace account setup run the following command:
#bs auth --force

#DOWNLOADING FASTQ FILES

#Run the following command to list the projects in the Basespace account
#Identify the project based on the project name and note the associated ID
bs list projects

ID=
FASTQ_PATH=

#Run the following command to pull FASTQs from the Basespace account
bs download project -i ${ID} -o ${FASTQ_PATH}  --extension=fastq.gz

#DOWNLOADING BCL FILES

#Run the following command to list runs in the Basespace account
#Identify the project based on the run and note the associated ID
#bs list runs

#Run the following command to pull BCL files from the Basespace account
#ID=
#BCL_PATH=
#bs download run -i ${ID} -o ${BCL_PATH}

echo "Download Completed"

