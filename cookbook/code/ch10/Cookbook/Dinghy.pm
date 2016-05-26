package Cookbook::Dinghy;

use strict;

sub new {

  my ($class, %args) = @_;

  return bless { _capacity => 2,
                 color     => $args{color} || 'navy',
                 count     => $args{count} || 0,
  }, $class;
}

sub check_load {

  my $self = shift;

  die 'We sunk' if ($self->{count} > $self->{_capacity});
}
1;
