package Cookbook::Multiplex;

use Apache::Constants qw(SERVER_ERROR REDIRECT);
use Apache::File;
use Apache::URI;

use strict;

my @sites = ();

sub handler {

  my $r = shift;

  # Check that the configuration data has been set previously
  # or that we can read it in now.
  unless (@sites || read_config()) {
    $r->log_error('unable to configure mirror sites list');
    return SERVER_ERROR;
  }
 
  # Create the URI for the mirror...
  my $site = Apache::URI->parse($r, $sites[rand @sites]);

  # ... and add the extra path info to the URI path.
  $site->path($site->path . $r->path_info);

  # Issue the redirect.
  $r->headers_out->set(Location => $site->unparse);
  return REDIRECT;
}

sub read_config {

  my $conf = Apache->server_root_relative('conf/CPAN.txt');

  my $fh = Apache::File->new($conf);

  unless ($fh) {
    print STDERR "Cannot open $conf: $!\n";
    return;
  }

  @sites = <$fh>;
  chomp @sites;
  return 1;
}
1;
