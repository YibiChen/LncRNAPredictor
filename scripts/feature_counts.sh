#!/bin/bash
genome=$1
trimmed_read_1=$2
trimmed_read_2=$3
annotation_gtf=$4
NCPUS=$4

WORKING_DIR=`pwd -P`
mkdir -p 8_featureCounts
cd 8_featureCounts

# mapping of the RNAseq reads to genome as inputs (i.e. bam files)
hisat2-build $genome $genome
hisat2 -x $genome -1 $WORKING_DIR/$trimmed_read_1 -2 $WORKING_DIR/$trimmed_read_2 | samtools view -bSh > RNAseq.bam

# count mapped read pairs
featureCounts  -T $NCPUS -p --countReadPairs -t exon  -g gene_id -a $WORKING_DIR/$annotation_gtf -s 2  -p -o featureCounts_pair.txt RNAseq.bam

cd $WORKING_DIR