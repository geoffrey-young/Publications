package Cookbook::Favicon;

use Apache::Constants qw(DECLINED);
use strict;

sub handler {
  my $r = shift;

  if ($r->uri =~ m!/favicon\.ico$!) {
    $r->uri("/images/favicon.ico");
    return DECLINED;
  }

  return DECLINED;
}
1;
