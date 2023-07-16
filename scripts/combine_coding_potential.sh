#!/bin/bash
PASA_trans=$1


cd 6_coding_potential

cat FEELnc_intergenic/*.lncRNA.fa feelnc_codpot_out_intergenic/*.noORF.fa|grep '>' | sed 's/>//' > FEELnc_intergenic.lncRNA.list
cat FEELnc_shuffle/*.lncRNA.fa feelnc_codpot_out_shuffle/*.noORF.fa|grep '>' | sed 's/>//' > FEELnc_shuffle.lncRNA.list


comm -12 <(grep 'noncoding' CPC2/all_candidate.results.txt | cut -f 1|sort) <(comm -12 <(cat FEELnc_intergenic.lncRNA.list |sort) <(cat FEELnc_shuffle.lncRNA.list|sort)|cut -f 1 -d ' '|sort) > consensus.lst
subset_fasta.py $WORKING_DIR/$PASA_trans consensus.lst consensus.fa


cd $WORKING_DIR