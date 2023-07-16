#!/bin/bash
gene_gff=$1
prefix=$2
candidates=$3
genome=$4

WORKING_DIR=`pwd -P`
mkdir -p 6_coding_potential/FEELnc_shuffle
cd 6_coding_potential/FEELnc_shuffle

# Coding_Potential
gffread $gene_gff -T -o ${prefix}.genome.gtf
FEELnc_codpot.pl -i ${WORKING_DIR}/${candidates} -a ${prefix}.genome.gtf  -g ${genome} --mode=shuffle --outdir="."


cd $WORKING_DIR