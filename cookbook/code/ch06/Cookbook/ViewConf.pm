package Cookbook::ViewConf;

use Apache::Constants qw(OK SERVER_ERROR NOT_FOUND);
use Apache::File;

use strict;

sub handler {

  my $r = shift;

  # Get the requested file.
  my $file = $r->filename;

  # Make sure it exists.
  unless (-f $r->finfo) {
    $r->log_error("$file does not exist");
    return NOT_FOUND;    
  }

  # Open up a filehandle.
  my $fh = Apache::File->new($file);

  unless ($fh) {
    $r->log_error("Cannot open $file: $!");
    return SERVER_ERROR;
  }

  $r->send_http_header('text/plain');

  # Get the size of the file, then send it along.
  my $size = -s _;
  my $sent = $r->send_fd($fh);

  $r->print(<<"END");

----------------------------------------------------
File size: $size
Bytes sent: $sent
----------------------------------------------------

END

  return OK;
}
1;
