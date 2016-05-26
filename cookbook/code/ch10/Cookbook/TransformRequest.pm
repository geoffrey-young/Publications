package Cookbook::TransformRequest;

use Apache::Request;

use strict;

@Cookbook::TransformRequest::ISA = qw(Apache::Request);

sub new {

  my ($class, $r, $input_transform, $output_transform) = @_;

  return bless { r                => Apache::Request->new($r),
                 input_transform  => $input_transform,
                 output_transform => $output_transform,
               }, $class;
}

sub param {

  my ($self, $field) = @_;

  my $transform = $self->{input_transform};

  return $self->SUPER::param($field) unless ($transform);

  return map { defined($_) ? &$transform($_) : undef}
    $self->SUPER::param($field);
}

sub print {

  my ($self, @args) = @_;

  @args = &{$self->{output_transform}}(@args)
    if $self->{output_transform};

  $self->SUPER::print(@args);
}
1;
