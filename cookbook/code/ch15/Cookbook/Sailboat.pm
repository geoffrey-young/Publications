package Cookbook::Sailboat;

use Apache::Constants qw(OK);

use strict;

sub dispatch_stats ($$) {

  my ($class, $r) = @_;

  $r->send_http_header('text/plain');
  $r->print("This ship has three sails.");

  return OK;
}

sub dispatch_maxspeed ($$) {

  my ($class, $r) = @_; 

  $r->send_http_header('text/plain');
  $r->print('10 knots');

  return OK;
}
1;
