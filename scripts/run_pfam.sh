#!/bin/bash
ncRNA_pep_fa=$1
combined_ncRNA_list=$2
ncRNA_bed=$3
genes_gff=$4

WORKING_DIR=`pwd -P`
mkdir -p 7_Pfam
cd 7_Pfam

#remove ncRNA with known pfam
samtools faidx  $WORKING_DIR/$ncRNA_pep_fa
sed 's/$/\.p1/' $WORKING_DIR/$combined_ncRNA_list > combined_ncRNA_list.orf
sed 's/$/\.p2/' $WORKING_DIR/$combined_ncRNA_list >> combined_ncRNA_list.orf
sed 's/$/\.p3/' $WORKING_DIR/$combined_ncRNA_list >> combined_ncRNA_list.orf
comm -12 <(cut -f 1 $WORKING_DIR/$ncRNA_pep_fa.fai|sort) <(cat combined_ncRNA_list.orf|sort) > combined_ncRNA_co_list.orf
xargs samtools faidx  $WORKING_DIR/$ncRNA_pep_fa < combined_ncRNA_co_list.orf > combined_ncRNA.orf.fa

pfam_scan.pl -fasta combined_ncRNA.orf.fa -dir /home/s4481587/programs/PfamScan/data -outfile combined_ncRNA.orf.fa.pfam
cat combined_ncRNA.orf.fa.pfam |cut -f 1 -d "."|sort|uniq > id_with_pfam.lst
comm -13 <(cat id_with_pfam.lst|sort) <(cat $WORKING_DIR/$combined_ncRNA_list|sort) > combined_ncRNA_candidates.lst

subset_ncRNA_bed.py combined_ncRNA_candidates.lst $WORKING_DIR/$ncRNA_bed > combined_ncRNA_candidates.bed
bedtools cluster -s -i combined_ncRNA_candidates.bed > combined_ncRNA_candidates.cluster
get_represent_ncRNA_bed.py combined_ncRNA_candidates.cluster > represent_ncRNA.cluster
cut -f 1,2,3,4,5,6,7,8,9,10,11,12 represent_ncRNA.cluster | sed 's/ID=//' > represent_ncRNA.bed

bed_to_gene_gff3.pl represent_ncRNA.bed > represent_ncRNA.gff3
gffread  represent_ncRNA.gff3 -T -o represent_ncRNA.gtf
gffread $genes_gff -T -o genes.gtf
cat represent_ncRNA.gtf genes.gtf > annotation.gtf

cd $WORKING_DIR