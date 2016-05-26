package Cookbook::Rules;

use Apache::Constants qw(OK);
use PDF::Create;

use strict;

sub handler {

  my $r = shift;

  my ($filename, $fh) = Apache::File->tmpfile;

  my $pdf = PDF::Create->new(filename => $filename);

  my $page = $pdf->new_page;

  $page->string($pdf->font, 20, 1, 770, "mod_perl rules");

  $pdf->close;

  # Rewind the file pointer.
  seek $fh, 0, 0;

  $r->set_content_length(-s $filename);

  $r->send_http_header('application/pdf');

  # Dump the file.
  $r->send_fd($fh);

  # $filename is removed at the end of the request.
  return OK;
}
1;
