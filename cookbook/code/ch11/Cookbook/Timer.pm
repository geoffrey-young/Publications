package Cookbook::Timer;

use Apache::Constants qw(OK);

use Time::HiRes qw(time);

use strict;

sub handler {

  my $r = shift;

  $r->pnotes(REQUEST_START => time);

  $r->push_handlers(PerlLogHandler => sub {
     my $r = shift;

     $r->log->info("The request took ",
                   time - $r->pnotes('REQUEST_START'),
                   " seconds");

     return OK;
  });

  return OK;
}
1;
