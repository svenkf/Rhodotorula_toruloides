#!/bin/bash

# Define input file containing UniProt IDs
input_file="lost_uniprotID.txt"

# Define output file for EC numbers
ec_output="lost_ecnumbers.txt"

# Function to query UniProt and get EC numbers
query_uniprot() {
    local input_file=$1
    local ec_output=$2

    # Empty or create the output file
    > "$ec_output"

    # Read the input file line by line
    while IFS= read -r line; do
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
        echo -e "$modified_line" >> "$ec_output"
    done < "$input_file"

    echo "EC numbers have been written to $ec_output"
}

# Query UniProt for the input file
query_uniprot $input_file $ec_output

echo "EC number fetching completed for $input_file."
