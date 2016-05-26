package Cookbook::Multiplex;

use Apache::File;
use Apache::URI;
use Apache::Constants qw(SERVER_ERROR REDIRECT);

use strict;

sub handler {

  my $r = shift;

  # Grab the <Location>.
  (my $location = $r->location) =~ s!^/!!;

  my $conf = $r->server_root_relative("conf/$location.txt");

  # Open the configuration file for reading.
  my $fh = Apache::File->new($conf);

  unless ($fh) {
    $r->log_error("Cannot open $conf: $!");
    return SERVER_ERROR;
  }

  my @sites = <$fh>;
  chomp @sites;

  # Create the URI for the mirror...
  my $uri = Apache::URI->parse($r, $sites[rand @sites]);

  # ... and add the extra path info to the URI path.
  $uri->path($uri->path . $r->path_info);

  # Issue the redirect.
  $r->headers_out->set(Location => $uri->unparse);
  return REDIRECT;
}
1;
