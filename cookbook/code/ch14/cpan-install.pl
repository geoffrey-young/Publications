#!/usr/bin/perl -w
use CPAN;

use strict;

# get the file, and extract the distribution name
my $file = $ARGV[0];
open (FILE, $file) or error_message("Cannot open '$file': $!");
chomp(my $dist = <FILE>);
close FILE or error_message("Cannot close '$file': $!");

# check that the name appears to be valid
error_message("$dist does not appear to be a valid distribution")
  unless $dist =~ m!^[/+\-.@\w]+\.(tar\.gz|tgz|zip)$!;

# give a chance to bail out
print "\n\nPreparing to install $dist\n\n";
print "Press Control-C to abort...\n";
sleep(7);

# install the distribution
CPAN::Shell->install($dist);

# have the user press <ENTER> to close the window
print "\nPress return to exit the window ";
my $ans = <STDIN>;

sub error_message {
  my $message = shift;
  warn "\n $message \n";
  sleep(10);
  die;
}
