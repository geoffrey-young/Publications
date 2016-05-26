package Cookbook::Speedboat;

use Apache::Constants qw(OK);

use strict;

sub dispatch_stats ($$) {

  my ($class, $r) = @_;

  $r->send_http_header('text/plain');
  $r->print("This boat has a large powerful 4.0l engine.");

  return OK;
}

sub dispatch_maxspeed ($$) {

  my ($class, $r) = @_; 

  $r->send_http_header('text/plain');
  $r->print('28 knots');

  return OK;
}
1;
