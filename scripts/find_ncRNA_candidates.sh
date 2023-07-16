#!/bin/bash
# output: ${prefix}_lncRNA_raw_candidates.lst, ${prefix}_lncRNA_raw_candidates.fa, ${prefix}_lncRNA_raw_candidates.bed
prefix=$1
gene_gff=$2   #  eg. ~/group/Cladocopium/DEG_Cgor/Patched_19Sep2022_Cladocopium_goreaui.genes.gff3
PASAassemb_bed=$3 # eg. Cladocopium_goreaui.genome.fa_pasadb.sqlite.pasa_assemblies.bed
PASAassemb_fa=$4 # eg. Cladocopium_goreaui.genome.fa_pasadb.sqlite.assemblies.fasta

WORKING_DIR=`pwd -P`
mkdir -p 5_ncRNA_candidates
cd 5_ncRNA_candidates
awk '$3=="exon"' $gene_gff > tmp.cds.gff3

bedtools intersect -a $WORKING_DIR/$PASAassemb_bed -v -s -split -b tmp.cds.gff3 |sed 's/ID=//' > ${prefix}_lncRNA_raw_candidates.bed
cut -f 4 ${prefix}_lncRNA_raw_candidates.bed > tmp.${prefix}_lncRNA_raw_candidates.lst
samtools faidx $WORKING_DIR/$PASAassemb_fa
comm -12 <(sort tmp.${prefix}_lncRNA_raw_candidates.lst) <(awk '$2>=200' $WORKING_DIR/${PASAassemb_fa}.fai|cut -f 1|sort) > ${prefix}_lncRNA_raw_candidates.lst

xargs samtools faidx $WORKING_DIR/$PASAassemb_fa < ${prefix}_lncRNA_raw_candidates.lst > ${prefix}_lncRNA_raw_candidates.fa
rm tmp.*
cd ..
