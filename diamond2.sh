#!/bin/bash

# Number of threads to use
NUM_THREADS=8

# Define file paths
DB_INPUT="CBS14_non_transmitted_seq.pep"
QUERY1="CBS349_non_transmitted_seq.pep"

# Define output files
DB_NAME="Rtoruloides_CBS14_db"
OUT1_DAA="CBS349_vs_CBS14.daa"
OUT1_TAB="CBS349_vs_CBS14.out"
FILTERED_OUT1_TAB="filtered_CBS349_vs_CBS14.out"

# Step 1: Prepare the database
echo "Creating DIAMOND database..."
diamond makedb --in $DB_INPUT -d $DB_NAME

# Step 2: Run DIAMOND BLASTP
echo "Running DIAMOND BLASTP for $QUERY1..."
diamond blastp -d $DB_NAME -q $QUERY1 -o $OUT1_DAA -e 1e-5 -p $NUM_THREADS --outfmt 100

# Step 3: Verify that DAA files are created correctly
if [[ ! -f "$OUT1_DAA" ]]; then
  echo "Error: Output file $OUT1_DAA was not created."
  exit 1
fi

# Step 4: Convert DAA output to tabular format
echo "Converting DAA output to tabular format..."
diamond view -a $OUT1_DAA -o $OUT1_TAB

# Step 5: Filter alignments with at least 80% similarity and 80% coverage
echo "Filtering alignments with at least 80% similarity and 80% coverage in $OUT1_TAB..."
filter_high_similarity_and_coverage() {
    local input_file=$1
    local output_file=$2

    awk '{
        similarity = $3
        alignment_length = $4
        query_length = $8 - $7 + 1
        coverage = (alignment_length / query_length) * 100

        if (similarity >= 80 && coverage >= 70) {
            print $0
        }
    }' $input_file > $output_file
}

filter_high_similarity_and_coverage $OUT1_TAB $FILTERED_OUT1_TAB

echo "Filtering completed. High similarity and coverage alignments saved in $FILTERED_OUT1_TAB."
