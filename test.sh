#!/bin/bash
echo "synopsis: "$0" TEST TRAIN[1..n]" 1>&2
echo "eval Glosser accuracy on test set TEST, using training set TRAIN" 1>&2;
echo 1>&2;

if javac Glosser.java; then
	TMP=$0.tmp;
	while [ -e $TMP ]; do
		TMP=$0.`ls $0* | wc -l`.tmp;
	done;
	echo > $TMP;	

	for train in $*; do
		if [ $train != $1 ]; then
			echo "processing "$train 1>&2;
			echo;
			cat $1 | java Glosser $train > $TMP;
			echo 1>&2;
			
			echo "<TAB>"$train;

			# total
			echo -n total'<TAB>';
			sed -e s/'^[^\t]*\t'// -e s/'\t.*'//g $1 | egrep . | wc -l

			echo -n total annotables'<TAB>';
			sed -e s/'^[^\t]*\t'// -e s/'\t.*'//g $1 | egrep . | grep -v '^_' | wc -l

			# baseline
			echo -n majority baseline' ';
			sed -e s/'^[^\t]*\t'// -e s/'\t.*'//g $1 | egrep . | grep -v '^_' | sort | uniq -c | sort -rn | head -n1 | sed s/'^\s*\([0-9][0-9]*\)\s\s*\([^\s][^\s]*\)\s*$'/'(\2)<TAB>\1'/g;

			echo -n first gloss baseline"<TAB>";
			cut -f 2,3 $TMP | grep -v '^_' | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;
			
			echo -n dict baseline"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\sD\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;
			
			echo -n D+Ia"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|Ia)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;
			
			echo -n D+Iab"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-b]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Iabc"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-c]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-d"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-d]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-e"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-e]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-f"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-f]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-g"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-g]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-h"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-h]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-i"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-i]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;

			echo -n D+Ia-j"<TAB>";
			cut -f 2,4,8 $TMP | grep -v '^_' | egrep '\s(D|I[a-j]*)\s' | cut -f 1,3 | egrep '^([^ ]*)\s\s*\1\s*$' | wc -l;
			
			echo;
		fi;
	done;
	
	echo 1>&2;
	echo perform heuristic confidence highlighting 1>&2
	cat $TMP | \
	perl -e '
		use Term::ANSIColor;
		use Term::ANSIColor qw(:constants);
		while(<>) {
			s/[\n\r]+//gs;
			
			print;
						
			my @line=split/\t/,$_;
			my $code = $line[3];
			my $left = $line[5];
			my $right= $line[6];
			my $mrg = $line[7];
			
			if($mrg=~m/.+/) {
				print "\t";
				if($code=~/^D$/) {
					print GREEN, $mrg, RESET;
				} elsif($code=~/^Ia$/) {
					print BRIGHT_BLUE, $mrg, RESET;
				} else {
					my $leftmatch = "";
					while(substr($left,0,1) eq substr($mrg,0,1) && length($mrg)>0 && length($left)>0) {
						$leftmatch=$leftmatch.substr($left,0,1);
						$left=substr($left,1);
						$mrg=substr($mrg,1);
					}
					my $rightmatch = "";
					while(substr($right,-1) eq substr($mrg,-1)  && length($mrg)>0 && length($right)>0) {
						$rightmatch=substr($right,-1).$rightmatch;
						$right=~s/.$//;
						$mrg=~s/.$//;
					}
					
					my $color=black;
					if($code eq Iab) { $color=grey1; }
					if($code eq Iabc) { $color=grey3; }
					if($code eq Iabcd) { $color=grey6; }
					if($code eq Iabcde) { $color=grey9; }
					if($code eq Iabcdef) { $color=grey12; }
					if($code eq Iabcdefg) { $color=grey15; }
					if($code eq Iabcdefgh) { $color=grey18; }
					if($code eq Iabcderghi) { $color=grey21; }
					if($code eq Iabcderghij){ $color=grey22; }
					
					if($leftmatch=~m/.+/) {
						print CYAN;
						print $leftmatch;
						print RESET;
					}
					if($mrg=~m/.+/) {
						print BOLD, color($color) , color(on_bright_cyan);
						print $mrg;
						print RESET;
					}
					if($rightmatch=~m/.+/) {
						print CYAN, $rightmatch, RESET;
					}
				}
			}
			
			print "\n";
		}
	';
		
	
	rm $TMP;
fi | sed s/'<TAB>'/'\t'/g;