#!/bin/bash

# Define the KEGG EC codes and their descriptions
declare -A ec_codes=(
    ["ec00061"]="Fatty Acid Biosynthesis"
    ["ec00561"]="Glycerolipid Metabolism"
    ["ec00564"]="Glycerophospholipid Metabolism"
    ["ec00600"]="Sphingolipid Metabolism"
    ["ec00100"]="Steroid Biosynthesis"
    ["ec00190"]="Oxidative Phosphorylation"
    ["ec00010"]="Glycolysis/Gluconeogenesis"
    ["ec00020"]="Citrate cycle (TCA cycle)"
    ["ec00030"]="Pentose Phosphate Pathway"
    ["ec00906"]="Carotenoid Biosynthesis"
    ["ec00830"]="Retinol Metabolism"
)

# Define categories and their corresponding EC codes
declare -A categories=(
    ["Lipid Synthesis"]="ec00061 ec00561 ec00564 ec00600 ec00100"
    ["Energy Metabolism"]="ec00190 ec00010 ec00020 ec00030"
    ["Carotenoid Biosynthesis"]="ec00906 ec00830"
    ["Cell Respiration"]="ec00190 ec00020"
)

# Define the input files and their corresponding output files
declare -A input_output_files=(
    ["kegg_links.out"]="final_links.txt"
    ["lost_kegg_links.txt"]="lost_final_links.txt"
)

# Iterate over each input file
for input_file in "${!input_output_files[@]}"; do
    output_file=${input_output_files[$input_file]}
    # Clear the output file
    > "$output_file"
    # Iterate over each category
    for category in "${!categories[@]}"; do
        echo -e "$category:\n" >> "$output_file"
        # Iterate over each EC code in the category
        for code in ${categories[$category]}; do
            description="${ec_codes[$code]}"
            url=$(grep -o "https://www.kegg.jp/kegg-bin/show_pathway?$code[^\"]*" "$input_file")
            if [[ -n "$url" ]]; then
                echo -e "$code - $description: $url\n" >> "$output_file"
            fi
        done
    done
done

echo "Extraction completed. URLs have been saved to final_links.txt and lost_final_links.txt."
