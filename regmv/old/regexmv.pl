#!/usr/bin/perl -w
# $Id: regexmv.pl,v 1.5 2012/07/21 19:44:55 bburke Exp $
# Perl util for renaming files with regular expressions
# Copyright (C) 2006 Benjamin Burke - http://bburke.galvanist.us/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
use File::Basename;

# initalize
my @inputFiles;
my $searchRegexp;
my $replaceStr;
my $allowOverwrite = 0;
my $test = 0;
my $verbose = 0;
my $processFlags = 1;

# process arguments until we encounter a --
while( defined((my $arg = shift(@ARGV))) ) {
   if ( $processFlags < 1 ) {
      push(@inputFiles, $arg);
   } else {
      my $tmp = undef;

      if ( $arg =~ /^--$/ ) {
         $processFlags = 0;
         push(@inputFiles, $arg);

      } elsif ( $arg =~ /^--search$/ ) {
         defined(($tmp = shift)) or &showHelp("--search requires an argument");
         $searchRegexp = qr/$tmp/o;

      } elsif ( $arg =~ /^--isearch$/ ) {
         defined(($tmp = shift)) or &showHelp("--isearch requires an argument");
         $searchRegexp = qr/$tmp/oi;

      } elsif ( $arg =~ /^--replace$/ ) {
         defined(($replaceStr = shift)) or &showHelp("--replace requires an argument");

      } elsif ( $arg =~ /^--overwrite$/ ) {
         $allowOverwrite++;

      } elsif ( $arg =~ /^--test$/ ) {
         $test++;

      } elsif ( $arg =~ /^--verbose$/ ) {
         $verbose++;

      } elsif ( $arg =~ /^-{1,2}h(elp)?$/i ) {
         &showHelp;

      } elsif ( $arg =~ /^-/i ) {
         die("Unknown flag \"$arg\" See --help for usage.\n");

      } else {
         push(@inputFiles, $arg);
         # $processFlags--;

      }
   }
}

# sanity check
&showHelp("Sanity Check Failed") unless (
   defined($searchRegexp) &&
   defined($replaceStr) &&
   $#inputFiles >= 0
);

# do it to it
foreach my $inputFilePath (@inputFiles) {
   # Separate the filename into useful chunks
   my ($oldFileName, $fileDir) = fileparse($inputFilePath);

   # if the fileBaseName matches the search regexp
   if ($oldFileName =~ $searchRegexp) {
      my ($newBaseName, $newFilePath);
      my @mvArgs;
      my $tmpReplaceStr = $replaceStr;

      # expand the replacement string's '\\x' style references
      {
         no strict 'refs';
         for(my $i = 1; defined(${$i}); $i++) {
            next unless defined(${$i});
            my $tmp = ${$i};
            $tmpReplaceStr =~ s/(?<!\\)\\\\$i/$tmp/gs;
         }
      }

      # apply the replacement to the filename and store in $newBaseName
      ($newBaseName = $oldFileName) =~ s/$searchRegexp/$tmpReplaceStr/;
      $newFilePath = join('', ($fileDir, $newBaseName));

      if ( $verbose ) {
         print STDERR $inputFilePath, ' => ', $newFilePath, "\n";
      }

      @mvArgs = ('--', $inputFilePath, $newFilePath);
      unshift(@mvArgs, '-i') unless ($allowOverwrite);

      if ( $test ) {
         unshift(@mvArgs, 'mv');
         system('echo', @mvArgs);
      } else {
         system('mv', @mvArgs);
      }
   } else {
      if ( $verbose > 1 ) {
         print STDERR "Skipping ", $inputFilePath, " because it doesn't match.\n";
      }
   }
}

exit;

# subroutines

sub showHelp() {
   my $message = ($#_ >= 0) ? shift : '';

   print STDERR "Usage: ", basename($0),
      " (--search <regexp>|--isearch <regexp>) --replace <arg> (--overwrite) (--help) <file> ...\n";
   print STDERR "   --search  <regexp> - Search regexp to be applied to filenames (case sensitive)\n";
   print STDERR "   --isearch <regexp> - Same as --search except matching will not be case sensitive\n";
   print STDERR "   --replace <string> - The string that will be used to replace the matched substring\n";
   print STDERR "   --overwrite        - Allow existing files to be overwritten (dangerous)\n";
   print STDERR "   --test             - Just show what would be renamed, don't actually do it\n";
   print STDERR "   --verbose          - Output additional information (multiple flags yields more info)\n";
   print STDERR "   --help             - This message\n";
   print STDERR "   <file> ...         - Filenames to scan for search and replace\n\n";

   print STDERR "Note that \\\\x (where x is an integer) style backreferences can be used in the replacement string\n\n";

   print STDERR '   notes: ', $message, "\n\n";

   exit -1;
}
