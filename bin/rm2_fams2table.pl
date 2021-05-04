#!/usr/local/bin/perl -w

### this script was written by Anna V.Protasio / date 18-02-2021
### last modified 28-04-2021
### it takes RM2 output (multifasta sequences) and produces a table summarising information from the fasta headers
### 

# fasta headers in RM2 output look like
# >ltr-1_family-1#LTR/Gypsy [ Type=LTR, Final Multiple Alignment Size = 9 ]
# >rnd-3_family-1#Unknown ( Recon Family Size = 19, Final Multiple Alignment Size = 16 )

use strict;
use warnings;

my $arg_count = @ARGV;
my $corr_args = 1;
if ($arg_count != $corr_args) {
  &print_usage;
  die "Please specify $corr_args arguments!";
}

my $in = shift; #the RM2 output

# open files
open( IN, "$in" ) or die "Cannot open IN file\n";
open( OUT, ">", "rm2header2table.tab") or die "Cannot open OUT file\n";


#print OUT  "Name\tOrder\tSuperfamily\tSubart\tmsa_size\n";
 
my $name = ""; 		# Family name (1st field)
my $order = ""; 	# Family order (1st field after #)
my $sfam = "";		# Family superfamily (2nd field after #)
my $subp = "";		# for LTRs, subpart can be LTR or INT
my $msas = ""; 		# size of the MSA as predicted by RM2


#loop through in file and collect fields for printing to out file
while (<IN>) {
	chomp ;
	if ($_=~/^>/) {
	my $t = $_; $t =~ s/,//g; # removes all comas from input
	my @line = split /\s+/, $t ;
		if 
		($line[0] =~/^>(ltr-\d+_family-\d+)\#(\w+)\/(\w+)/) {
		$name = $1; $order = $2; $sfam = $3; $subp = $line[2]; $msas = $line[8];
		#print OUT "$name\t$order\t$sfam\t$subp\t$msas\n";
		} 
		elsif 
		($line[0] =~/^>(rnd-\d+_family-\d+)\#(\w+)\/(\w+)/) {
		$name = $1; $order = $2; $sfam = $3; $subp = "NA"; $msas = $line[12];
		#print OUT "$name\t$order\t$sfam\t$subp\t$msas\n";
		}
		elsif 
		($line[0] =~/^>(rnd-\d+_family-\d+)\#(\w+)/) {
		$name = $1; $order = $2; $sfam = "NA"; $subp = "NA"; $msas = $line[12];
		#print OUT "$name\t$order\t$sfam\t$subp\t$msas\n";
		}
	print OUT "$name\t$order\t$sfam\t$subp\t$msas\n";
	}
}

	
 
close IN;
close OUT;


print "TABLE file generated. All done!\n" ;

sub print_usage {
  
  print "Usage: $0 <rm2.db-families.fa> \n";
  print "  <rm2.db-families.fa> = output file from running RepeatModeler2\n";
  
}

exit

