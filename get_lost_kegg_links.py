import pandas as pd
import requests
from bs4 import BeautifulSoup
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

# Define the file paths for the input file and the output file
input_file_path = 'lost_ecnumbers.txt'
output_file_path = 'lost_kegg_links.txt'
RETRY_LIMIT = 5
RETRY_DELAY = 5  # seconds

# Function to get the pathways from KEGG entry page
def get_kegg_pathways(ec_number):
    url = f"https://www.kegg.jp/entry/{ec_number}"
    retry_count = 0
    while retry_count < RETRY_LIMIT:
        response = requests.get(url)
        if response.status_code == 200:
            print(f"Successfully fetched the KEGG entry page for EC number: {ec_number}")
            soup = BeautifulSoup(response.text, 'html.parser')
            pathway_td = soup.find(string="Pathway")
            if pathway_td:
                pathways_section = pathway_td.find_next('td').find_all('a')
                pathway_codes = [link.text for link in pathways_section]
                print(f"Pathway codes for EC number {ec_number}: {pathway_codes}")
                return pathway_codes
            else:
                print(f"Pathway section not found for EC number: {ec_number}")
                return []
        elif response.status_code == 403:
            print(f"403 Forbidden for EC number: {ec_number}. Retrying {retry_count + 1}/{RETRY_LIMIT}...")
            retry_count += 1
            time.sleep(RETRY_DELAY)
        else:
            print(f"Failed to retrieve KEGG entry page for EC number: {ec_number} - Status Code: {response.status_code}")
            print(f"Response content: {response.text}")
            break
    return []

# Function to process each line
def process_line(ec_num, df):
    if ec_num not in df.iloc[:, -1].values:
        print(f"EC number {ec_num} not found in DataFrame.")
        return []
    line = df[df.iloc[:, -1] == ec_num].iloc[0].to_string(header=False, index=False)
    parts = line.strip().split()
    ec_number = parts[-1]
    pathways = get_kegg_pathways(ec_number)
    urls = [f"{pathway}+{ec_number}%20green" for pathway in pathways]
    return urls

# Read the input file and initialize a dictionary to hold the combined URLs
df = pd.read_csv(input_file_path, sep="\s+", header=None)
combined_urls = defaultdict(list)

# Use ThreadPoolExecutor to parallelize the processing
with ThreadPoolExecutor(max_workers=16) as executor:
    futures = []
    ec_numbers = df.iloc[:, -1]
    ec_numbers_filtered = ec_numbers[ec_numbers != "-"]
    for ec_num in ec_numbers_filtered:
        futures.append(executor.submit(process_line, ec_num, df))

    for future in as_completed(futures):
        urls = future.result()
        for url in urls:
            pathway_code = url.split('+')[0]
            ec_color_info = url.split('+')[1]
            combined_urls[pathway_code].append(ec_color_info)

# Save the combined URLs to a file in the desired format
with open(output_file_path, 'w') as output_file:
    for pathway_code, ec_color_infos in combined_urls.items():
        unique_ec_color_infos = list(set(ec_color_infos))  # Ensure EC numbers are unique
        combined_ec_colors = '+'.join([ec_color_info for ec_color_info in unique_ec_color_infos])
        combined_url = f"https://www.kegg.jp/kegg-bin/show_pathway?{pathway_code}+" + combined_ec_colors
        output_file.write(f"{pathway_code}:\n{combined_url}\n\n")

print(f"Combined URLs have been saved to {output_file_path}")
