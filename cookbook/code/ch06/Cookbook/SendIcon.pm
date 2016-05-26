package Cookbook::SendIcon;

use Apache::Constants qw(OK SERVER_ERROR);
use Apache::File;

use DirHandle;

use strict;

sub handler {

  my $r = shift;

  # Get the icons/ directory relative to ServerRoot.
  my $icons = $r->server_root_relative('icons');
  my $dh = DirHandle->new($icons);
  unless ($dh) {
    $r->log_error("Cannot open directory $icons: $!");
    return SERVER_ERROR;
  }

  # Get the directory contents, and populate @icons with any gifs found.
  my @icons;

  foreach my $icon ($dh->read) {
    my $sub = $r->lookup_uri("/icons/$icon");
    next unless $sub->content_type eq 'image/gif';
    push @icons, $sub->filename;
  }

  # Select a random image.
  my $image = $icons[rand @icons];

  # Open up the selected image and send it to the client.
  my $fh = Apache::File->new($image);
  unless ($fh) {
    $r->log_error("Cannot open image $image: $!");
    return SERVER_ERROR;
  } 

  binmode $fh;  # required for Win32 systems

  $r->send_http_header('image/gif');

  $r->send_fd($fh);

  # Flush the buffer so the data is sent immediately.
  $r->rflush;

  # Simulate some long-running process...
  sleep(5);

  return OK;
}
1;
