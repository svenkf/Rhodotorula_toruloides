#!/bin/bash

# Define the URL and file names
taxonomy_id=5533
fasta_file="uniprot_rhodotorula.fasta"
diamond_db="rhodotorula_db.dmnd"
query_file="lost_sequences.fa"
diamond_output="lost_uniprotID.txt"

# Number of threads to use for DIAMOND
num_threads=8

# Download the Rhodotorula database from UniProt (commented out)
# echo "Downloading Rhodotorula database from UniProt..."
# wget --tries=10 --timeout=30 "https://rest.uniprot.org/uniprotkb/stream?query=taxonomy_id:${taxonomy_id}&format=fasta" -O ${fasta_file}

# Create the DIAMOND database
echo "Creating DIAMOND database..."
diamond makedb --in ${fasta_file} -d ${diamond_db}

# Run DIAMOND BLASTP for the query file
echo "Running DIAMOND BLASTP for ${query_file}..."
diamond blastp --query "${query_file}" --db ${diamond_db} --out "${diamond_output}" --outfmt 6 --threads ${num_threads} --max-target-seqs 1 --evalue 0.001

echo "DIAMOND BLASTP run complete. Results saved to ${diamond_output}."
