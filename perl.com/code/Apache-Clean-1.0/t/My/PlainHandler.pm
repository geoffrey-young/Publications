package My::PlainHandler;

use Apache::Constants qw(OK);

use Apache::Filter;

use strict;

sub handler {

  my $r = shift->filter_register;

  $r->send_http_header('text/plain');
  $r->print(qq!<i    ><strong>&quot;This is a test&quot;</strong></i   >!);

  return OK;
}

1;
