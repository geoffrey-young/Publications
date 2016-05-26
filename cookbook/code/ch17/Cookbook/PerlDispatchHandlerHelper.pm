package Cookbook::PerlDispatchHandlerHelper;

use Apache::Constants (SERVER_ERROR);

use 5.006;
use Exporter ();

use strict;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(call_handler);

sub call_handler {

  my ($r, $handler) = @_;

  my $status = undef;

  if (ref $handler eq 'CODE') {
    # Handler is already a CV, so just run it.
    $status = $handler->($r);
  }
  elsif ((my $sub = $handler) =~ m/sub\s*{/) {
    # Handle anonymous subroutines.
    $handler = eval $sub;
    $status = $handler->($r);
  }
  elsif (my ($class, $method) = $handler =~ m/(.*)->(.*)/) {
    # Handle explicit method handlers.
    my $cv = $class->can($method);
    $status = $class->$cv($r) if $cv;
  }
  elsif (my $cv = UNIVERSAL::can(($handler =~ m/(.*)::(.*)/)[0,1])) {
    # Handle explicitly named handler subroutine.
    $status = $cv->($r) if $cv;
  }
  else {
    # Default to handler().
    $cv = UNIVERSAL::can($handler, 'handler');
    $status = $cv->($r) if $cv;
  }

  $r->log_error('Cookbook::PerlDispatchHandlerHelper: ',
                'could not dispatch to ', $handler) unless defined $status;

  return defined $status ? $status : SERVER_ERROR;
}
1;
