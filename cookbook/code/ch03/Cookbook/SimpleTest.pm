package Cookbook::SimpleTest;

use Apache::Constants qw(OK);

use Cookbook::SimpleRequest qw(assbackwards);

use strict;

sub handler {

  my $r = shift;

  # Get the old value and set the current value
  # to supress the headers.
  my $old = assbackwards($r, 1);

  # Verify the new value.
  my $new = assbackwards($r);

  $r->send_http_header('text/plain');

  $r->print("look ma, no headers!\n");
  $r->print("old: $old, new $new\n");

  return OK;
}
1;
