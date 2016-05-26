package Cookbook::CheckConnection;

use IO::Select;

use strict;

sub client_connected {

  my $c = Apache->request->connection;

  # First, check to see whether Apache tripped the aborted flag.
  return if $c->aborted;

  # Now for the real test.
  # Check to see if we can read from the output file descriptor.
  my $s = IO::Select->new($c->fileno);

  return if $s->can_read(0);

  # Looks like the client is still there...
  return 1;
}
1;
