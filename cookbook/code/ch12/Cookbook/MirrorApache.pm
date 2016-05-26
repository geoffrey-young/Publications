package Cookbool::MirrorApache;

use Apache::Constants qw(OK DECLINED);

use strict;

sub handler {

  my $r = shift;

  return DECLINED unless $r->proxyreq;

  my (undef, $file) = $r->uri =~ m!^http://(www|httpd).apache.org/(.*)!;

  return DECLINED unless $file;

  if ($file =~ m!^docs/!) {
    # Replace requests to the online docs with our local version.

    $file =~ s!^docs/!manual/!;

    $file = join "/", ($r->document_root, $file);

    if (-e $file) {
      # Use the local disk...
      $r->filename($file);

      # ... and unset the proxy flag so Apache runs the
      # MIME-type checking phase.
      $r->proxyreq(0);

      return OK;
    }
    # We didn't have a local file, so fall through...
  }
  elsif ($file =~ m!^dist/!) {
    # Save apache.org's server by using a mirror instead.

    my @mirrors = $r->dir_config->get('ApacheDistMirror');

    # Whoops, no mirrors configured?
    return DECLINED unless @mirrors;

    $file =~ s!^dist/!!;

    $r->filename(join "", ("proxy:", $mirrors[rand @mirrors], $file));

    return OK;
  }

  return DECLINED;
}
1;
