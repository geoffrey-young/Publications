package My::Long;

use Apache::RequestIO ();  # for $r->print
use Apache::RequestRec (); # for $r->content_type

use Apache::Const -compile => qw(OK);

use strict;

sub handler {

  my $r = shift;

  $r->content_type('text/html');
  my $buffer = 'x' x $r->args;
  $r->print(qq!$buffer<strong></strong>!);

  return Apache::OK;
}

1;
