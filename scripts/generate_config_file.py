import sys,json,os

data_path=sys.argv[1]

output={}
samples = [d for d in os.listdir(data_path) if os.path.isdir(os.path.join(data_path, d))]
reads=set()
pair_end=False
sample2trimmed_reads={}
for sample in samples:
    sample2trimmed_reads[sample]=set()
    for file in os.listdir(os.path.join(data_path,sample)):
        for extention in (".fastq.gz",".fastq"):
            if file.endswith(extention):
                file_prefix=file[:-len(extention)]
                if (file_prefix.endswith("_1") or file_prefix.endswith("_2")):
                    pair_end=True
                    file_prefix=file_prefix[:-2]

                reads.add(os.path.join(sample,file_prefix))
                trimmed_read="PREFIX_"+os.path.join(sample,file_prefix)+"_SURFIX"
                sample2trimmed_reads[sample].add(trimmed_read)
    sample2trimmed_reads[sample]=",".join(list(sample2trimmed_reads[sample]))

output["python_path"] = "/home/s4481587/programs/miniconda3/bin/python3.9"
output["scripts_path"] = "/scratch/project_mnt/S0026/YibiChen/ncRNA_workflow/scripts"
output["CPC2_path"]="/home/s4481587/programs/CPC2_standalone-1.0.1/bin/CPC2.py" 
output["FEELnc_config"]="/home/s4481587/programs/FEELnc/env.sh"
output["data_path"]=data_path
output["samples"] = samples
output["pair_end"] = pair_end
output["reads"] = list(reads)
output["sample2trimmed_reads"] = sample2trimmed_reads
with open('config.json', 'w') as f:
    json.dump(output, f)