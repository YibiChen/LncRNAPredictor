# Open the file containing the old and new names
import sys

abv=sys.argv[1]
ncRNA_gff3=sys.argv[2]

name_dict = {}
with open(ncRNA_gff3, 'r') as f:
    for line in f:
        fields = line.strip().split('\t')
        if len(fields) >1:
            if fields[2] == "gene":
                info=fields[8].split(";")
                old_name=info[1].split("=")[1]
                new_name=abv+"_"+info[0].split("=")[1]
                name_dict[old_name]=new_name



# Open the fasta file and create a new file for the renamed sequences
with open('final_ncRNA.fasta', 'r') as f, open('final_ncRNA_renamed.fasta', 'w') as out:
    # Iterate through the fasta file
    for line in f:
        # If the line is a header line
        if line.startswith('>'):
            # Get the old sequence name
            old_name = line.strip()[1:]
            # If the old name is in the name dictionary, replace it with the new name
            if old_name in name_dict:
                new_name = name_dict[old_name]
                # Write the new header line to the output file
                out.write(f'>{new_name}\n')
            # If the old name is not in the dictionary, keep the original name
            else:
                out.write(line)
        # If the line is not a header line, write it to the output file as-is
        else:
            out.write(line)
