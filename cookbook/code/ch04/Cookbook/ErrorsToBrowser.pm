package Cookbook::ErrorsToBrowser;

# Print out the last N lines of the error_log.
# Probably not a good idea for production, but
# helpful when debugging development code.

use Apache::Constants qw(OK);
use Apache::File;

use strict;

sub handler {

  my $r = shift;

  my $lines = $r->dir_config('ErrorLines') || 5;

  # Make sure that the file contains a full path.
  my $error_log   = $r->server_root_relative($r->server->error_fname);

  my $fh = Apache::File->new($error_log);

  my @lines;

  while (my $line = <$fh>) {
    shift @lines if (push @lines, $line) > $lines;
  }

  $r->send_http_header('text/plain');
  print @lines;

  return OK;
}
1;
