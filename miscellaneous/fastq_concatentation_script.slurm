#!/bin/bash
#SBATCH --partition=debug
#SBATCH --account=weisenbe_1344
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=128GB
#SBATCH --time=1:00:00



#Paths
Run1_Path="/project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/miscellaneous/Lenz_Moonshot_16S_Project/Lenz_16S_20241113"
Run2_Path="/project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/miscellaneous/Lenz_Moonshot_16S_Project/Lenz_16S_20241119"
Output_Path="/project/weisenbe_1344/Complete_David_870_Project_Directory_Transfer/Projects/miscellaneous/Lenz_Moonshot_16S_Project/concatenated_fastqs"

for FILE_R1 in "$Run1_Path"/*_L001_R1_001.fastq.gz; do
    #Extracting Sample name
    SAMPLE=$(basename "$FILE_R1" | sed 's/_L001_R1_001.fastq.gz//')
    echo "$SAMPLE identified"
    #Finding remaining R1 and R2 files from both runs
    FILE_R2="$Run1_Path/${SAMPLE}_L001_R2_001.fastq.gz"
    FILE_R1_Run2="$Run2_Path/${SAMPLE}_L001_R1_001.fastq.gz"
    FILE_R2_Run2="$Run2_Path/${SAMPLE}_L001_R2_001.fastq.gz"
    
    echo "$FILE_R2"
    echo "$FILE_R1_Run2"
    echo "$FILE_R2_Run2"

    if [[ -f "$FILE_R2" && -f "$FILE_R1_Run2" && -f "$FILE_R2_Run2" ]]; then
        echo "Concatenating sample: $SAMPLE"
        #Concatenate R1
        cat "$FILE_R1" "$FILE_R1_Run2" > "${Output_Path}/${SAMPLE}_L001_R1_001.fastq.gz"
        #Concatenate R2
        cat "$FILE_R2" "$FILE_R2_Run2" > "${Output_Path}/${SAMPLE}_L001_R2_001.fastq.gz"
    else
        echo "Warning: $SAMPLE not processed properly. Skip"
    fi
done 

 

