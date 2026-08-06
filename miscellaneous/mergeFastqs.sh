#!/bin/bash

# Get command line arguments
output_file="$1"
input_files=("${@:2}") # Starting from the second argument, add all remaining arguments to an array

# Merge files
zcat "${input_files[@]}" | gzip > "$output_file"

echo "Fastq files merged successfully into $output_file."

# Check if the line counts match
total_lines=0
for input_file in "${input_files[@]}"; do
    lines=$(zcat "$input_file" | wc -l)
    total_lines=$((total_lines + lines))
done
output_lines=$(zcat "$output_file" | wc -l)
if [ "$output_lines" -eq "$total_lines" ]; then
    echo "Line count check passed: all files have the same number of lines."
else
    echo "Error: line count check failed: the merged file has a different number of lines than the input files."
fi

