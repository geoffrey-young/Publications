package Cookbook::Apache;

use Apache;

use 5.006;
use DynaLoader;

use strict;

our @ISA = qw(DynaLoader Apache);
our $VERSION = '0.01';

__PACKAGE__->bootstrap($VERSION);

sub new {

  my ($class, $r) = @_;

  $r ||= Apache->request;

  return bless { r => $r }, $class;
}

sub bytes_sent {
  return sprintf("%.0f", shift->_bytes_sent);
}
1;
