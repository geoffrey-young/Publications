package Cookbook::CPANRedirect;

use Apache::Constants qw(OK);
use strict;

sub handler {
   my $r = shift;

   $r->internal_redirect($r->path_info);

   return OK;
}
1;
