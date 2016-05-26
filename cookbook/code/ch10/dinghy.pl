#!/usr/bin/perl -w

use Cookbook::Dinghy;

use strict;

my $lifeboat = Cookbook::Dinghy->new(count => 2);

$lifeboat->check_load;

print "We are still floating.\n"
