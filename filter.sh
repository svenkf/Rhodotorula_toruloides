#!/bin/bash

# Input files
INPUT_FILE1="CBS14_vs_CBS6016.out"
INPUT_FILE2="CBS349_vs_CBS6016.out"

# Output files for best alignments
BEST_OUTPUT_FILE1="best_CBS14_vs_CBS6016.out"
BEST_OUTPUT_FILE2="best_CBS349_vs_CBS6016.out"

# Output files for filtered alignments
FILTERED_OUTPUT_FILE1="filtered_best_CBS14_vs_CBS6016.out"
FILTERED_OUTPUT_FILE2="filtered_best_CBS349_vs_CBS6016.out"

# Final output files
FINAL_OUTPUT_FILE1="final_CBS14.out"
FINAL_OUTPUT_FILE2="final_CBS349.out"

# Function to extract the best alignments based on a combined score of similarity and alignment length
extract_best_alignments() {
    local input_file=$1
    local output_file=$2

    awk '{
        ref = $2;
        similarity = $3;
        alignment_length = $4;
        combined_score = similarity * alignment_length;
        if (ref in best) {
            if (combined_score > best[ref]) {
                best[ref] = combined_score;
                best_line[ref] = $0;
            }
        } else {
            best[ref] = combined_score;
            best_line[ref] = $0;
        }
    } END {
        for (ref in best_line) {
            print best_line[ref];
        }
    }' $input_file > $output_file
}

# Function to filter alignments based on similarity and coverage
filter_alignments() {
    local input_file=$1
    local output_file=$2

    awk '{
        similarity = $3;
        alignment_length = $4;
        query_start = $7;
        query_end = $8;
        query_length = query_end - query_start + 1;
        coverage = (alignment_length / query_length) * 100;

        if (similarity >= 90 && coverage >= 70) {
            print $0;
        }
    }' $input_file > $output_file
}

# Extract the best alignments from both input files
extract_best_alignments $INPUT_FILE1 $BEST_OUTPUT_FILE1
extract_best_alignments $INPUT_FILE2 $BEST_OUTPUT_FILE2

# Filter the best alignments based on similarity and coverage
filter_alignments $BEST_OUTPUT_FILE1 $FILTERED_OUTPUT_FILE1
filter_alignments $BEST_OUTPUT_FILE2 $FILTERED_OUTPUT_FILE2

# Compare the filtered best alignments and output the best ones for common references
# and unique ones to their respective files
awk '
    FNR==NR {
        ref = $2;
        data1[ref] = $0;
        sim1[ref] = $3;
        length1[ref] = $4;
        combined_score1[ref] = sim1[ref] * length1[ref];
        next
    }
    {
        ref = $2;
        sim2 = $3;
        length2 = $4;
        combined_score2 = sim2 * length2;
        if (ref in data1) {
            if (combined_score1[ref] > combined_score2) {
                print data1[ref] > "'"$FINAL_OUTPUT_FILE1"'"
            } else {
                print $0 > "'"$FINAL_OUTPUT_FILE2"'"
            }
            delete data1[ref]
        } else {
            print $0 > "'"$FINAL_OUTPUT_FILE2"'"
        }
    }
    END {
        for (ref in data1) {
            print data1[ref] > "'"$FINAL_OUTPUT_FILE1"'"
        }
    }
' $FILTERED_OUTPUT_FILE1 $FILTERED_OUTPUT_FILE2

echo "Best alignments extracted, filtered, and compared. Results saved in $FINAL_OUTPUT_FILE1 and $FINAL_OUTPUT_FILE2."
