package Cookbook::UPPERCASE;

use Apache::Constants qw(OK);

use Cookbook::TransformRequest;

use strict;

sub handler {

  my $r = Cookbook::TransformRequest->new(shift, undef, sub {uc join('', @_)} );

  $r->send_http_header('text/plain');
  $r->print("all output is in Upper case");

  return OK;
}
1;
