package Cookbook::TestLanguagePriority;

use Cookbook::LanguagePriority;

use Apache::Constants qw(OK);

use strict;

sub handler {

  my $r = shift;

  my $cfg = Cookbook::LanguagePriority->get($r);

  $r->send_http_header('text/plain');

  print "Here is the current LanguagePriority:\n";
  print join " -> ", @{$cfg->priority};

  return OK;
}
1;
