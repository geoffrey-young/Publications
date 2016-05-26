package Cookbook::WormsBeGone;

use Apache::Constants qw(OK FORBIDDEN DECLINED SERVER_ERROR);

use strict;

sub handler {

  my $r = shift;

  my $ip  = $r->connection->remote_ip;
  my $uri = $r->uri;

  my $bad_ip_dir = $r->dir_config->get('BadIPdir');
  my @bad_urls   = $r->dir_config->get('BadURLs');

  # Do not run if no is directory defined.
  return DECLINED unless ($bad_ip_dir);

  # Forbid access if we know the incoming IP is bad already.
  return FORBIDDEN if (-f "$bad_ip_dir/$ip");

  foreach my $bad_url (@bad_urls) {
    if (index($uri, $bad_url) == 0) {
      # Request is from a worm or Script Kiddie, so
      # create a file for the IP address...
      open(TOUCHFILE, ">$bad_ip_dir/$ip") or return SERVER_ERROR;
      close(TOUCHFILE);

      # ... and forbid access.
      return FORBIDDEN;
    }
  }

  return OK;
}
1;
