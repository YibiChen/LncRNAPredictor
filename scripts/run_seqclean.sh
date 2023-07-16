#!/bin/bash

INPUT=$1
THREADS=$2

mkdir -p 3_SeqClean/
cd 3_SeqClean

ln -s ../${INPUT} transcripts.fa
${PASA}/pasa-plugins/seqclean/seqclean/seqclean transcripts.fa -v ${UNIVEC} -c ${THREADS}
cd ..