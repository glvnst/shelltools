#!/usr/bin/perl -w
#use strict;

my $sum = 0;
my $addends = 0;

my $min;
my $max;
my $rangeInit = 0;

while(<>) {
   # We want to be able to match ".1" "0.1" "1.1" "1."
   next unless ( $_ =~ /^\s*(          (\s*\-\s*)?((\.\d+)|(\d+\.\d*)|(\d+))                )\b/x );

   my $inNum = $1 +0.0;
   if ( !$rangeInit ) {
      $min = $max = $1;
      $rangeInit = 1;
   }

   $min = $1 if ( $1 < $min );
   $max = $1 if ( $1 > $max );

   $sum += $1;
   ++$addends;
}

if ( $addends > 0 ) {
   print STDOUT
   "    Avg: ", ( $sum / $addends ), "\n",
   "    Sum: $sum\n",
   "Addends: $addends\n",
   "  Range: $min-$max\n";
}

exit;
