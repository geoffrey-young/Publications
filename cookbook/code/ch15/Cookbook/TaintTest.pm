package Cookbook::TaintTest;

use Apache::Constants qw(OK);

use Cookbook::TaintRequest;

use strict;

sub handler {

  my $r = Cookbook::TaintRequest->new(shift);

  my @data = $r->args;

  # Untaint input data if the magic word "override" is present.
  $data[1] =~ m/(.*override.*)/;
  $data[1] = $1 if $1;

  $r->send_http_header('text/html');
  $r->print("<html>You entered ", @data, "<br/></html>");

  return OK;
}
1;
