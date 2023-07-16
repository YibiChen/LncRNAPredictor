#!/bin/bash
INPUT=$1


WORKING_DIR=`pwd -P`
mkdir -p 6_coding_potential/CPC2
cd 6_coding_potential/CPC2

CPC2.py -i $WORKING_DIR/$INPUT -o all_candicate.results

cd $WORKING_DIR