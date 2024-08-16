#!/bin/bash

# Define the URL and file names
taxonomy_id=5533
fasta_file="uniprot_rhodotorula.fasta"
diamond_db="rhodotorula_db.dmnd"
query_file1="CBS349_origin_seq.pep"
query_file2="CBS14_origin_seq.pep"
query_file3="CBS6016_no_alignments.pep"
diamond_output1="uniprotID_CBS349.txt"
diamond_output2="uniprotID_CBS14.txt"
diamond_output3="uniprotID_CBS6016.txt"

# Number of threads to use for DIAMOND
num_threads=8

# Download the Rhodotorula database from UniProt
#echo "Downloading Rhodotorula database from UniProt..."
#wget --tries=10 --timeout=30 "https://rest.uniprot.org/uniprotkb/stream?query=taxonomy_id:${taxonomy_id}&format=fasta" -O ${fasta_file}

# Create the DIAMOND database
#echo "Creating DIAMOND database..."
#diamond makedb --in ${fasta_file} --db ${diamond_db}

# Function to run DIAMOND BLASTP
run_diamond_blastp() {
  local query_file=$1
  local diamond_output=$2
  echo "Running DIAMOND BLASTP for ${query_file}..."
  diamond blastp --query "${query_file}" --db ${diamond_db} --out "${diamond_output}" --outfmt 6 --threads ${num_threads} --max-target-seqs 1 --evalue 0.001
}

# Run DIAMOND BLASTP for the first query file
run_diamond_blastp ${query_file1} ${diamond_output1}

# Run DIAMOND BLASTP for the second query file
run_diamond_blastp ${query_file2} ${diamond_output2}

# Run DIAMOND BLASTP for the third query file
run_diamond_blastp ${query_file3} ${diamond_output3}

echo "DIAMOND BLASTP runs complete. Results saved to ${diamond_output1}, ${diamond_output2}, and ${diamond_output3}."
