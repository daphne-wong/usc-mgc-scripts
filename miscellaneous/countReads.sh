#!/bin/bash

# Get the input directory as a command line argument
fastq_dir=$1

# Set the output file name
output_file=$2

# Write the header to the output file
echo "File Name,Reads" > $output_file

# Loop through all the fastq files in the directory
for file in $fastq_dir/*.fastq.gz
do
  # Get the file name without the path and extension
  file_name=$(basename $file .fastq.gz)
  
  # Count the number of reads in the file and store in a variable
  reads=$(zcat $file | wc -l | awk '{print $1/4}')
  
  # Write the file name and number of reads to the output file
  echo "$file_name,$reads" >> $output_file
done

