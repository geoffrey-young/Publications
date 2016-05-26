package My::Uppercase;

use Apache::Filter ();

use Apache::Const -compile => qw(OK);

use strict;

sub handler {

  my $f   = shift;

  while ($f->read(my $buffer, 1024)) {
    $f->print(uc $buffer);
  }

  return Apache::OK;
}

1;
