package Cookbook::CPANInstall;

use Apache::Constants qw(OK DECLINED);

use strict;

sub handler {

  my $r = shift;

  my $dist;

  # Decline unless the request is for a distribution.
  return DECLINED unless
    ($dist = $r->uri) =~ s!.*authors/id/(.*)\.(tar\.gz|tgz|zip)$!$1.$2!;

  # Save the distribution name.
  $r->notes(DIST => $dist);

  # Set the Content handler to send_name().
  $r->handler('perl-script');
  $r->set_handlers(PerlHandler => [\&send_name]);

  return OK;
}

sub send_name {

  my $r = shift;

  # Change the MIME type.
  $r->content_type('application/x-cpan');

  # Set the filename to save as 'dist.CPAN'.
  $r->headers_out->set('Content-Disposition' =>
                       'inline; filename=dist.CPAN');

  # Just send the distribution name.
  $r->send_http_header;
  $r->print($r->notes('DIST'));

  return OK;
}
1;
