#!/bin/bash 

# modified from https://gist.github.com/l-modolo/e6f8a044b5526085b5fd

if [ $# -ne 1 ] 
then 
echo -e "\nUsage: `basename $0` <input.fa>\n"

echo -e "Description: Calculates the length of each fasta entry in fasta file. Works with any number of entries.\n"

echo -e "Input: a FASTA formated file with 1 or more entries.\n" 

echo -e "Output: a space separated file with fasta id and length in nt.\n"

echo -e "Requires: awk / grep.\n"
echo -e "Modified from https://gist.github.com/l-modolo/e6f8a044b5526085b5fd"
exit
fi


input=$1

awk 'BEGIN {OFS = "\n"}; /^>/ {print(substr(sequence_id, 2)" "sequence_length); sequence_length = 0; sequence_id = $0}; /^[^>]/ {sequence_length += length($0)}; END {print(substr(sequence_id, 2)" "sequence_length)}' $input | grep "\S" > $input.len

