#!/bin/bash

# Define input files
DB_PEP1="Rtoruloides_CBS349_metaeuk_stringtie.fna.transdecoder.pep"
DB_PEP2="hybrid_flye_pilon_metaeuk_stringtie.fna.transdecoder.pep"
REFERENCE_FASTA="Rtoruloides_CBS6016_metaeuk_stringtie.fna.transdecoder.pep"
BLAST_OUT1="final_CBS349.out"
BLAST_OUT2="final_CBS14.out"
FILTERED_BEST_OUT1="filtered_best_CBS349_vs_CBS6016.out"
FILTERED_BEST_OUT2="filtered_best_CBS14_vs_CBS6016.out"

# Define output files for matched sequences
MATCHED_PEP1="CBS349_origin_seq.pep"
MATCHED_PEP2="CBS14_origin_seq.pep"

# Define output files for non-matched sequences
NON_MATCHED_PEP1="CBS349_non_transmitted_seq.pep"
NON_MATCHED_PEP2="CBS14_non_transmitted_seq.pep"
NON_MATCHED_REFERENCE="CBS6016_no_alignments.pep"

# Define temporary files
TEMP_FILE1="unique_CBS349_vs_CBS6016.txt"
TEMP_FILE2="unique_CBS14_vs_CBS6016.txt"
TEMP_FILE3="combined_unique_CBS14_CBS349_vs_CBS6016.txt"
TEMP_FILE4="all_CBS6016_ids.txt"
TEMP_FILE5="no_alignment_CBS6016_ids.txt"

# Extract unique sequence IDs from the second column of both filtered alignment files
awk '{print $2}' $BLAST_OUT1 | sort -u > $TEMP_FILE1
awk '{print $2}' $BLAST_OUT2 | sort -u > $TEMP_FILE2

# Combine the unique IDs from both filtered files
cat $TEMP_FILE1 $TEMP_FILE2 | sort -u > $TEMP_FILE3

# Extract all sequence IDs from the CBS6016 peptide file
grep '^>' $REFERENCE_FASTA | sed 's/^>//;s/ .*//' > $TEMP_FILE4

# Find sequence IDs in CBS6016 that are not in the combined unique list
grep -v -F -f $TEMP_FILE3 $TEMP_FILE4 > $TEMP_FILE5

# Function to extract sequences from a fasta file based on a list of IDs
extract_sequences() {
    local ids_file=$1
    local input_fasta=$2
    local output_fasta=$3
    awk 'BEGIN {
        while ((getline < "'"${ids_file}"'") > 0) ids[$1] = 1
    }
    /^>/ {
        header = substr($0, 2)
        split(header, id, " ")
        if (id[1] in ids) {
            print_flag = 1
            print $0
        } else {
            print_flag = 0
        }
    }
    print_flag && !/^>/ {print}' "$input_fasta" > "$output_fasta"
}

# Function to extract non-matched sequences from a fasta file
extract_non_matched_sequences() {
    local matched_ids_file=$1
    local input_fasta=$2
    local output_fasta=$3
    awk 'BEGIN {
        while ((getline < "'"${matched_ids_file}"'") > 0) matched_ids[$1] = 1
    }
    /^>/ {
        header = substr($0, 2)
        split(header, id, " ")
        if (!(id[1] in matched_ids)) {
            print_flag = 1
            print $0
        } else {
            print_flag = 0
        }
    }
    print_flag && !/^>/ {print}' "$input_fasta" > "$output_fasta"
}

# Extract matched sequences for CBS349 and CBS14 separately from the reference
extract_sequences $TEMP_FILE1 $REFERENCE_FASTA $MATCHED_PEP1
extract_sequences $TEMP_FILE2 $REFERENCE_FASTA $MATCHED_PEP2

# Extract non-matched sequences for CBS349 and CBS14 separately from their own peptide files using filtered_best output files
awk '{print $1}' $FILTERED_BEST_OUT1 | sort -u > temp_CBS349_blast.txt
awk '{print $1}' $FILTERED_BEST_OUT2 | sort -u > temp_CBS14_blast.txt

extract_non_matched_sequences temp_CBS349_blast.txt $DB_PEP1 $NON_MATCHED_PEP1
extract_non_matched_sequences temp_CBS14_blast.txt $DB_PEP2 $NON_MATCHED_PEP2

# Extract non-matched sequences from the reference (CBS6016)
extract_sequences $TEMP_FILE5 $REFERENCE_FASTA $NON_MATCHED_REFERENCE

# Function to count sequences in a fasta file
count_sequences() {
    local fasta_file=$1
    grep -c '^>' "$fasta_file"
}

# Count sequences in each peptide file
total_cbs349=$(count_sequences $DB_PEP1)
total_cbs14=$(count_sequences $DB_PEP2)
total_cbs6016=$(count_sequences $REFERENCE_FASTA)

# Print the summarized results
echo "Summary of sequence extraction:"
echo "Number of matched sequences with CBS349: $(count_sequences $MATCHED_PEP1)"
echo "Number of non-transmitted sequences from CBS349: $(count_sequences $NON_MATCHED_PEP1)"
echo "Number of matched sequences for CBS14: $(count_sequences $MATCHED_PEP2)"
echo "Number of non-transmitted sequences from CBS14: $(count_sequences $NON_MATCHED_PEP2)"
echo "Number of non-matched sequences from CBS6016: $(count_sequences $NON_MATCHED_REFERENCE)"
echo "Total sequences in CBS349 peptide file: $total_cbs349"
echo "Total sequences in CBS14 peptide file: $total_cbs14"
echo "Total sequences in CBS6016 peptide file: $total_cbs6016"

# Clean up temporary files
rm $TEMP_FILE1 $TEMP_FILE2 $TEMP_FILE3 $TEMP_FILE4 $TEMP_FILE5 temp_CBS349_blast.txt temp_CBS14_blast.txt

echo "Extraction completed. Matched sequences saved in $MATCHED_PEP1 and $MATCHED_PEP2."
echo "Non-matched sequences saved in $NON_MATCHED_PEP1 and $NON_MATCHED_PEP2."
echo "Non-matched sequences from reference saved in $NON_MATCHED_REFERENCE."
