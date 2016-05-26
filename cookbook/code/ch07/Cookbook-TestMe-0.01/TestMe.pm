package Cookbook::TestMe;

use Apache::Constants qw(OK);
use Apache::File;

our $VERSION = '0.01';

sub handler {
  my $r = shift;

  if (lc($r->dir_config('Filter')) eq 'on') {
    $r = $r->filter_register;
    ($fh, $status) = $r->filter_input;
    return $status unless $status == OK
  } else {
    $fh = Apache::File->new($r->filename);
  }
 
  $r->send_http_header('text/plain');
  print while <$fh>;

  return OK;
}
1;
