package My::Uppercase;

use Apache::Constants qw(OK);

use Apache::Filter;

use strict;

sub handler {

  my $r = shift->filter_register;

  my ($fh, $status) = $r->filter_input;

  return $status unless $status == OK;

  $r->send_http_header();

  while (my $line = <$fh>) {
    print uc $line;
  }
    
  return OK;
}
  
1;
