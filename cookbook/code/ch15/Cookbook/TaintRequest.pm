package Cookbook::TaintRequest;

use Apache;
use Apache::Util qw(escape_html);

# Module load will die if PerlTaintChecks Off
use Taint qw(tainted);

use strict;

@Cookbook::TaintRequest::ISA = qw(Apache);

sub new {

  my ($class, $r) = @_;

  $r ||= Apache->request;

  tie *STDOUT, $class, $r;

  return tied *STDOUT;
}

sub print {

  my ($self, @data) = @_;

  foreach my $value (@data) {
    # Dereference scalar references.
    $value = $$value if ref $value eq 'SCALAR';

    # Escape any HTML content if the data is tainted.
    $value = escape_html($value) if tainted($value);
  }

  $self->SUPER::print(@data);
}

sub TIEHANDLE {

  my ($class, $r) = @_;

  return bless { r => $r }, $class;
}

sub PRINT {
  shift->print(@_);
}
1;
