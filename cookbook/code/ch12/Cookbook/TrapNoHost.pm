package Cookbook::TrapNoHost;

use Apache::Constants qw(DECLINED BAD_REQUEST);
use Apache::URI;

use strict;

sub handler {

  my $r = shift;

  # Valid requests for name based virtual hosting are:
  # requests with a Host header, or
  # requests that are absolute URIs.

  unless ($r->headers_in->get('Host') || $r->parsed_uri->hostname) {

    $r->custom_response(BAD_REQUEST, 
                        "Oops!  Did you mean to omit a Host header?");

    return BAD_REQUEST;
  }

  return DECLINED;
}
1;
