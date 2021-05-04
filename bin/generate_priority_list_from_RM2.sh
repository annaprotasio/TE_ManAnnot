#!/bin/bash

if [ $# -ne 4 ]
then
    echo -e "\nusage: `basename $0` <RM2output.fa> <genome.fa> <pfam_db_dir> <github_repo_DIR>\n"
    echo -e "DESCRIPTION: 	This script runs a little pipeline that: 1) reduces sequence redundancy from <RM2output.fa> using cd-hit-est; 2) extract info from RM2 fasta headers; 3) for each RM2 family, makes a rough estimate of the number of copies in the genome; 4) calculates no of Pfam domains in each putative RM2 family and 5) calculates length of consensus.\n"

    echo -e "REQUIRES: 	Installation of pfam_scan.pl and their database, cd-hit, blast OR Use conda install recommendations from paper and activate the environment before running this script.\n"

    echo -e "INPUT:       	<RM2output.fa>		output from RM2 often with the ending `rm2.db-families.fa` "
    echo -e "             	<genome.fa>			genome used to predict the library"
    echo -e "             	<pfam_db_DIR>		path to the Pfam database directory"
	echo -e "             	<github_repo_DIR>	path to the local github repo (previously downloaded), for example \"~/Desktop/path_to_dir/TE_tools_avp25/\" "
    echo -e "OUTPUT:	    A table; columns are: consensus name, RM2 superfmaily prediction, RM2 family prediction, INR/LTR, consensus length (nt)  \n"     

    exit
fi

rmout=$1
genome=$2
pfamdb=$3
repo=$4

# P2 reduce redundancy

FILE=cdhit.fa.clstr
if [ ! -f "$FILE" ]; then
    echo "cd-hit-est has not be run. Running cd-hit-est, this can take some time"
   cd-hit-est -i $rmout -o cdhit.fa -aS 0.8 -c 0.8 -G 0
fi

# P1 extract info from headers from cd-hit-output

perl $repo/bin/rm2_fams2table.pl cdhit.fa # makes cdhit.fa.tab

sort cdhit.fa.tab | awk '{OFS="\t"; $NF=""; print $0}' > col1.txt

# P4 obtain sequence length

# samtools faidx cdhit.fa
# sort cdhit.fa.fai | awk '{print $2}' > col2.txt
# sort cdhit.fa.fai | awk '{print $1}' > fam_names.txt

bash $repo/bin/get_fasta_length.sh cdhit.fa
awk '{print $2}' cdhit.fa.len > col2.txt

# P5 blast hits

FILE=$genome.nin
if [ ! -f "$FILE" ]; then
    echo "Blast database doesn't exists. Running makeblastdb, this can take some time"
    makeblastdb -in $genome -dbtype nucl
fi

blastn -query cdhit.fa -db $genome -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen" | awk '{OFS="\t"; if ($3 >= 80 && (($4/$13) > 0.5 ) ) {print $0,$4/$13}  }' > genome.blast.o

cat fam_names.txt genome.blast.o | sed 's/\#/ /g' | awk '{print $1}' | sort | uniq -c | awk '{print $1-1}' > col3.txt

# P3 predict domains with Pfam

getorf -sequence cdhit.fa -outseq cdhit.orf -minsize 300

FILE=./pfam.results
if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist. Running Pfam, this can take some time"
    pfam_scan.pl -fasta cdhit.orf -dir $pfamdb > pfam.results
fi

awk '{if ($6~/^PF/) {print $1}}' < pfam.results | sed 's/\#/ /1' | awk '{print $1}' | sort > pf.domains.count

grep '>' cdhit.fa | sed 's/\#/ /1;s/^>//g' | awk '{print $1}' >> pf.domains.count

cat pf.domains.count | sort | uniq -c | awk '{print $1-1}' > col4.txt


# paste all outputs

paste -d "\t" col1.txt col2.txt col3.txt col4.txt > final_priority.table.tab






