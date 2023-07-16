import sys
from Bio import SeqIO

fasta_file = sys.argv[1]
target_list = sys.argv[2]
output_file = sys.argv[3]

record_dict = SeqIO.to_dict(SeqIO.parse(fasta_file, "fasta"))

target_seqs = []
with open(target_list) as f:
    for line in f:
        seq_id=line.strip()
        target_seqs.append(record_dict[seq_id])

SeqIO.write(target_seqs, output_file, "fasta")