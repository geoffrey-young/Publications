package Cookbook::NNTP;

use Apache::Constants qw(OK);

use Net::NNTP;

use strict;

my %cache = ();

sub handler {
  
  my @servers = Apache->server->dir_config('NNTPhosts');

  # Pre-connect NNTP connections at child init.
  foreach my $server (@servers) {
    $cache{$server} = Net::NNTP->new($server);
  }

  return OK;
}

sub connect_cached {

  my ($self, $server) = @_;

  # Return the connection if we have one in this child.
  return $cache{$server} if $cache{$server}

  # Otherwise, create a new connection and store it.
  return $cache{$server} = Net::NNTP->new($server);
}
1;
