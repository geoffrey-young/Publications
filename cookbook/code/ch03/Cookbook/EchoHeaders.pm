package Cookbook::EchoHeaders;

use Apache::Constants qw (OK);

use strict;

sub handler {

  my $r = shift;

  # Grab all of the headers at once...
  my %headers_in = $r->headers_in;

  # ... or get a specific header and do something with it.
  my $gzip = $r->headers_in->get('Accept-Encoding') =~ m/gzip/;

  $r->send_http_header('text/plain');

  print "The host in your URL is: ", $headers_in{'Host'}, "\n";
  print "Your browser is: ",         $headers_in{'User-Agent'}, "\n";
  print "Your browser accepts gzip encoded data\n" if $gzip;;

  return OK;
}
1;
