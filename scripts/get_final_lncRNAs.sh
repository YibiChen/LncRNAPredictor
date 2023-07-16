#!/bin/bash
ncRNA_bed=$1
ncRNA_fasta=$2
prefix=$3
ncRNA_gff3=$4


WORKING_DIR=`pwd -P`

cd 8_featureCounts

cut -f  $WORKING_DIR/$ncRNA_bed > final_ncRNA.lst
xargs samtools faidx $ncRNA_fasta < final_ncRNA.lst > final_ncRNA.fasta
python3 rename_final_ncRNA.py Pcor $ncRNA_gff3

cd $WORKING_DIR
ln -s 8_featureCounts/final_ncRNA_renamed.fasta .