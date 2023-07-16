# LncRNAPredictor
lncRNA prediction pipeline using genome and transcriptome data

Long non-coding RNAs (lncRNAs), defined as RNAs longer than 200 nucleotides that are not translated into functional proteins, are widely expressed and have key roles in gene regulation. However, lncRNAs studies so far are focusing on model organisms while lncRNAs in non-model organisms remain to be studied. Here I present a de novo lncRNA prediction pipeline for non-model organisms using genome and transritpome data. See details in https://doi.org/10.1101/2023.06.27.546665

# installation 
1. clone the repo.
```
git clone https://github.com/YibiChen/LncRNAPredictor.git
```
2. download and install dependencies. \
   Programs: 
     * bedtools 
     * BLASTALL 
     * bowtie2 
    *  CPC2 
     * FEELnc 
    *  gffread 
    *  hisat2 
     * jellyfish 
     * MINIMAP2 
    *  PASA 
    *  salmon 
   *   samtools 
    *  subread  
   
   libraries: 
    *  pythonlib:snakemake 
    *  Rlib:ggplot2;seqlogo 
   
   database: 
    * UNIVEC 

# Run the pipeline
configurate config.yaml by editing it with any plain text editor. See examples:
```
---
sample: test   # usually the species id
read1: /scratch/d85/yc1401/snakemake/test2/A_1.fastq.gz  # absolute path of RNAseq read file 1
read2: /scratch/d85/yc1401/snakemake/test2/A_2.fastq.gz  # absolute path of RNAseq read file 2
genome_file: /scratch/d85/yc1401/snakemake/test/test.genome.fa  # absolute path of genome assembly 
gene_annotation: /scratch/d85/yc1401/snakemake/test/test.gff3  # absolute path of gene annotation in gff3 format
max_intron_length: 70000  # max allowed intron length of lncRNAs
```

Export all dependencies to PATH, then Run the pipeline from the base directory

```
cd LncRNAPredictor
source src/env.sh  # you may need to configure this file according to your installed path
snakemake --cores all
```

# TODO
build a docker image to include all dependencies.


