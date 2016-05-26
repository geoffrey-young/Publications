package My::PlainHandler;

use Apache::RequestIO ();  # for $r->print
use Apache::RequestRec (); # for $r->content_type

use Apache::Const -compile => qw(OK);

use strict;

sub handler {

  my $r = shift;

  $r->content_type('text/plain');
  $r->print(q!<i    ><strong>&quot;This is a test&quot;</strong></i   >!);

  return Apache::OK;
}

1;
