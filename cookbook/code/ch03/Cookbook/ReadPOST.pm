package Cookbook::ReadPOST;

use Apache::Constants qw(OK);

use strict;

sub handler {

  my $r = shift;

  my $content;

  $r->read($content, $r->header_in('Content-length'));

  $r->send_http_header('text/html');

  $r->print("<html><body>\n");
  $r->print("<h1>Reading data</h1>\n");

  my (@pairs) = split(/[&;]/, $content);

  foreach my $pair (@pairs) {
    my ($parameter, $value) = split('=', $pair, 2);
    $r->print("$parameter has value $value<br>\n");
  }

  $r->print("</body></html>\n");

  return OK;
}
1;
