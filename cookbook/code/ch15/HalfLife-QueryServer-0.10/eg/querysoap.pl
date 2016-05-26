#!/usr/bin/perl

use SOAP::Lite +autodispatch =>
  uri => 'http://www.example.com/HalfLife/QueryServer',
  proxy => 'http://www.example.com/game-query';

use strict;

my $hl = HalfLife::QueryServer->new('10.3.4.200');

$hl->ping;

foreach my $method (qw(map os type server description)) {
  print $hl->$method(), "\n";
}
