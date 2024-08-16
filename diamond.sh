#!/bin/bash

# Number of threads to use
NUM_THREADS=8

# Define file paths
DB_INPUT="Rtoruloides_CBS6016_metaeuk_stringtie.fna.transdecoder.pep"
QUERY1="Rtoruloides_CBS349_metaeuk_stringtie.fna.transdecoder.pep"
QUERY2="hybrid_flye_pilon_metaeuk_stringtie.fna.transdecoder.pep"

# Define output files
DB_NAME="Rtoruloides_CBS6016_db"
OUT1_DAA="CBS349_vs_CBS6016.daa"
OUT2_DAA="CBS14_vs_CBS6016.daa"
OUT1_TAB="CBS349_vs_CBS6016.out"
OUT2_TAB="CBS14_vs_CBS6016.out"

# Step 1: Prepare the database
echo "Creating DIAMOND database..."
diamond makedb --in $DB_INPUT -d $DB_NAME

# Step 2: Run DIAMOND BLASTP for the first query
echo "Running DIAMOND BLASTP for $QUERY1..."
diamond blastp -d $DB_NAME -q $QUERY1 -o $OUT1_DAA -e 1e-5 -p $NUM_THREADS --outfmt 100

# Step 3: Run DIAMOND BLASTP for the second query
echo "Running DIAMOND BLASTP for $QUERY2..."
diamond blastp -d $DB_NAME -q $QUERY2 -o $OUT2_DAA -e 1e-5 -p $NUM_THREADS --outfmt 100

# Step 4: Verify that DAA files are created correctly
if [[ ! -f "$OUT1_DAA" ]]; then
  echo "Error: Output file $OUT1_DAA was not created."
  exit 1
fi

if [[ ! -f "$OUT2_DAA" ]]; then
  echo "Error: Output file $OUT2_DAA was not created."
  exit 1
fi

# Step 5: Convert DAA output to tabular format
echo "Converting DAA output to tabular format..."
diamond view -a $OUT1_DAA -o $OUT1_TAB
diamond view -a $OUT2_DAA -o $OUT2_TAB

echo "DIAMOND searches and conversion completed."
