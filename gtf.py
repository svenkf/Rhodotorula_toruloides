import re

def extract_gene_ids(out_file):
    gene_ids = set()
    with open(out_file, 'r') as file:
        for line in file:
            columns = line.split()
            reference = columns[1]
            match = re.search(r'Rtoruloides_CBS6016_(\d+).p1', reference)
            if match:
                gene_id = match.group(1)
                gene_ids.add(gene_id)
    return gene_ids

def filter_gtf(gtf_file, gene_ids, output_file):
    with open(gtf_file, 'r') as gtf, open(output_file, 'w') as out:
        for line in gtf:
            # Skip header lines
            if line.startswith('#'):
                continue

            # Ensure the line has enough columns and contains a gene_id
            columns = line.split('\t')
            if len(columns) > 2 and columns[2] == 'gene':
                gene_id_match = re.search(r'gene_id "MSTRG\.(\d+)"', line)
                if gene_id_match and gene_id_match.group(1) in gene_ids:
                    out.write(line)

# Define file paths
gtf_file = 'Rtoruloides_CBS6016_metaeuk_stringtie.gtf'
out_files = [
    ('final_CBS349.out', 'CBS349_origin.gtf'),
    ('final_CBS14.out', 'CBS14_origin.gtf')
]

# Process each out file
for out_file, output_file in out_files:
    gene_ids = extract_gene_ids(out_file)
    filter_gtf(gtf_file, gene_ids, output_file)

# Filter GTF for sequences with no alignments
all_gene_ids = set()
for out_file, _ in out_files:
    all_gene_ids.update(extract_gene_ids(out_file))

filter_gtf(gtf_file, all_gene_ids, 'CBS6016_no_alignments.gtf')

print("Filtered GTF files created.")
