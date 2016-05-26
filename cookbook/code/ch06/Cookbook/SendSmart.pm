package Cookbook::SendSmart;

use Apache::Constants qw( OK NOT_FOUND );
use Apache::File;

use File::MMagic;
use IO::File;

use strict;

sub handler {
  # Send a static file with correct conditional headers
  # only if the client can't use what it already has.

  my $r = shift;

  # Not Apache::File->new() because File::MMagic needs $fh->seek().
  my $fh = IO::File->new($r->filename);
 
  return NOT_FOUND unless $fh;
 
  # Set the MIME type magically
  $r->content_type(File::MMagic->new->checktype_filehandle($fh));
 
  # Set the Last-Modified header based on the file modification time...
  $r->set_last_modified((stat $r->finfo)[9]);

  # ... and set the Etag and Content-Length headers.
  $r->set_etag;
  $r->set_content_length;
 
  # Now, if all the If-* headers say we're good to go, send the headers.
  # Otherwise, return a status and let Apache handle it from here.
  if ((my $status = $r->meets_conditions) == OK) {
    $r->send_http_header;
  }
  else {
    return $status;
  }
 
  # Rewind the file pointer and send the content.
  seek $fh, 0, 0;
  $r->send_fd($fh);
 
  return OK ;
}
1;
