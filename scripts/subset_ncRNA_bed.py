import sys

nc_list_file = sys.argv[1]
all_candidates_bed_file = sys.argv[2]

nc_list = set()
with open(nc_list_file) as f:
    for line in f:
        id = line.strip()
        nc_list.add(id)


with open(all_candidates_bed_file) as f:
    for line in f:
        id = line.strip().split("\t")[3]
        if id.startswith("ID="):
            id=id[3:]
        if id in nc_list:
            print (line.strip())
