#!/bin/bash

# Define input files containing UniProt IDs
input_file1="uniprotID_CBS349.txt"
input_file2="uniprotID_CBS14.txt"
input_file3="uniprotID_CBS6016.txt"

# Define output files for EC numbers
ec_output1="ec_CBS349.txt"
ec_output2="ec_CBS14.txt"
ec_output3="ec_CBS6016.txt"

# Function to query UniProt and get EC numbers
query_uniprot() {
    local line=$1
    local file=$2

    # Extract UniProt ID from the line (assuming format tr|ID|...)
    uniprot_id=$(echo "$line" | awk '{print $2}' | cut -d'|' -f2)
    echo "Processing UniProt ID: $uniprot_id"

    # Query the UniProt API for the corresponding EC number
    response=$(curl -sG --header "Accept: application/json" \
                    --data-urlencode "query=accession:$uniprot_id" \
                    --data-urlencode "fields=accession,ec" \
                    "https://rest.uniprot.org/uniprotkb/search")

    # Parse the EC number from the response using jq
    ec_number=$(echo "$response" | jq -r '.results[0].proteinDescription.recommendedName.ecNumbers[0].value')

    # Check if an EC number was found and set it to "-" if not found
    if [[ "$ec_number" == "null" || -z "$ec_number" ]]; then
        ec_number="-"
    fi
    echo "EC number for $uniprot_id: $ec_number"

    # Append the EC number to the line
    modified_line="$line\t$ec_number"

    # Write the modified line to the output file
    echo -e "$modified_line" >> "$file"
}

# Empty or create the output files
> "$ec_output1"
> "$ec_output2"
> "$ec_output3"

# Process each line in the input file for CBS349
while IFS= read -r line; do
    query_uniprot "$line" "$ec_output1"
done < "$input_file1"

# Process each line in the input file for CBS14
while IFS= read -r line; do
    query_uniprot "$line" "$ec_output2"
done < "$input_file2"

# Process each line in the input file for CBS6016
while IFS= read -r line; do
    query_uniprot "$line" "$ec_output3"
done < "$input_file3"

echo "EC numbers have been written to $ec_output1, $ec_output2, and $ec_output3"
