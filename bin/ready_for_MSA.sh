#!/bin/bash
if [ $# -ne 2 ] 
then 
    echo -e "\nUSAGE:         `basename $0` <input.multi.fa> <max_number_sequences>"
   
    echo -e "\nDESCRIPTION:   Reduces the number of sequences (entries) for alignment." 
    echo -e "               First, the algorithm takes 1/4 of the largest  sequences from the multifasta <input.multi.fa> file."
    echo -e "               Second, it randomly selects  more sequences until completing a total of <max_number_sequences>."
     echo -e "               It also creates a *subset.len file, which indicates the lenghts and genomic coordinates corresponding to the subset of selected sequences."
      echo -e "             If <input.multi.fa> has less sequences than <max_number_sequences>, the script does not have any effect and a message is printed to stdout. "
               
   echo -e "\nINPUT:        <input.multi.fa> is a multi-fasta file (e.g output from 'make_fasta_from_blast.sh') and > 100 entries."
   echo -e "              <max_number_sequences> must be a positive integer."
   
   echo -e "\nOUTPUT:       rdmSubset.fa and rdmSubset.len files " 
   echo -e "REQUIRES:     Samtools must be installed"
			     
    exit
    
fi

fasta=$1
max=$2

samtools faidx $fasta  

export P="$fasta.fai"  
temp=$(wc -l < "$P") # temp variable is initialized with an integer corresponding to the number of sequences in the multiFasta file. 
if [ $temp -gt $max ] # Only files with more sequences than the user selected threshold enter the if statement. 
    then
	             
        sort -nk 2 -r $fasta.fai > $fasta.fai.sortedbylength 
        ((l = $max/4))  #l is the number of largest sequences to be selected. (If $max/4 is not an integer, bash truncates to it by cutting off digits after decimal point).
        r=$(($max-$l)) #r is the number sequences to be randomly selected             
        head -$l $fasta.fai.sortedbylength | awk '{print $1}' >> $fasta.headers #headears of "l" largest seqs
        awk "NR> $l {print}" < $fasta.fai.sortedbylength > $fasta.temp 
        sort -R $fasta.temp | head -$r | awk '{print $1}' >> $fasta.headers #headers of "l" plus "r" random seqs 
        grep -A 1 -f $fasta.headers $fasta | sed '/^--/d' > $fasta.rdmSubset.fa  
        awk 'FNR==NR{a[$1]=$2;next} {print $1,a[$1]}' $fasta.fai $fasta.headers | sort -nk 2 -r >> $fasta.rdmSubset.len
        rm $fasta.fai.sortedbylength $fasta.headers $fasta.temp 
    else
        echo "I am sorry, the number of sequences in the multifasta file named "$fasta", should be greater than the selected threshold of $max"
fi
rm $fasta.fai