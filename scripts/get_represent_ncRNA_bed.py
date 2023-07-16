import sys

all_candidates_bed_file = sys.argv[1]


to_be_release = []
last_cluster = None

with open(all_candidates_bed_file) as f:
    for line in f:
        cluster_id = line.strip().split("\t")[12]
        if cluster_id != last_cluster:
            if len(to_be_release) > 0:
                print (to_be_release[0][0])
                to_be_release=[]
        last_cluster = cluster_id
        transcript_exon_lens = line.strip().split("\t")[10].split(",")
        transcript_len = sum([int(x) for x in transcript_exon_lens])
        to_be_release.append((line.strip(),transcript_len))
        to_be_release.sort(key=lambda x:x[1], reverse=True)
    if len(to_be_release) > 0:
                print (to_be_release[0][0])
                to_be_release=[]
