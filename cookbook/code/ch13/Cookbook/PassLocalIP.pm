package Cookbook::PassLocalIP;

use Apache::Constants qw(OK);

use strict;

sub handler {

  my $r = shift;

  # We don't need to do anything if Apache is going to
  # skip authentication anyway.
  return OK unless $r->some_auth_required;

  # Get the list of IP masks to allow.
  my @IPlist = $r->dir_config->get('PassIP');

  if (grep {$r->connection->remote_ip =~ m/^\Q$_/} @IPlist) {
    # Disable authentication if coming from an allowed IP...
    $r->set_handlers(PerlAuthenHandler => [\&OK]);

    # ... and disable authorization if that's also configured
    $r->set_handlers(PerlAuthzHandler =>[\&OK])
      if grep { lc($_->{requirement}) ne 'valid-user' } @{$r->requires};
  }

  return OK;
}
1;
