#!/bin/bash

# Define input files
FILTERED_RESULTS="filtered_CBS349_vs_CBS14.out"
FASTA_FILE="hybrid_flye_pilon_metaeuk_stringtie.fna.transdecoder.pep"
OUTPUT_FASTA="lost_sequences.fa"

# Extract sequence IDs from the second column of the filtered results
SEQ_IDS=$(awk '{print $2}' $FILTERED_RESULTS | sort | uniq)

# Function to extract sequences from FASTA file
extract_sequences() {
    local fasta_file=$1
    local seq_ids=$2
    local output_fasta=$3

    # Create an empty output file
    > $output_fasta

    # Loop through each sequence ID and extract the sequence
    for seq_id in $seq_ids; do
        awk -v id="$seq_id" -v found=0 '
        /^>/ {found=0}
        /^>/{if($0 ~ id){print $0; found=1; next}}
        {if(found)print $0}
        ' $fasta_file >> $output_fasta
    done
}

# Extract the sequences
echo "Extracting sequences from $FASTA_FILE..."
extract_sequences $FASTA_FILE "$SEQ_IDS" $OUTPUT_FASTA

echo "Extraction completed. Sequences saved in $OUTPUT_FASTA."
