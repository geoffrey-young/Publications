package Cookbook::Apache;

use Apache;

use strict;

@Cookbook::Apache::ISA = qw(Apache);

sub new {

  my ($class, $r) = @_;

  $r ||= Apache->request;

  return bless { r => $r }, $class;
}

sub bytes_sent {
  # This overrides the Apache bytes_sent() method, and
  # simply returns the value in (rounded) KB.

  return sprintf("%.0f", shift->SUPER::bytes_sent / 1024);
}
1;
