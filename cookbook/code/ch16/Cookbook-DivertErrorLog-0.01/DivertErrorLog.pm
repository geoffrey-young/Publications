package Cookbook::DivertErrorLog;

use DynaLoader ();
use Exporter ();

use strict;

our @ISA = qw(DynaLoader Exporter);

our @EXPORT_OK = qw(set_error_log restore_error_log);

our $VERSION = '0.01';

__PACKAGE__->bootstrap($VERSION);

use strict;

sub set_error_log {

  my $arg = shift;

  # The input can be either a filename or an open filehandle.
  # In either case, we need to isolate a file descriptor
  # for the file.
  my $fd  = fileno($arg);

  unless (defined $fd) {
     open(OUT, ">$arg") or return;
     $fd = fileno(*OUT);
  }

  # Call our XS set() routine, passing in an
  # Apache::Server object and the file descriptor.
  set(Apache->server, $fd);
}

sub restore_error_log {
  # Call our XS restore() routine, passing in an
  # Apache::Server object.

  restore(Apache->server);
}
1;
