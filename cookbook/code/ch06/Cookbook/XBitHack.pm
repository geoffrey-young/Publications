package Cookbook::XBitHack;

use Apache::Constants qw(OK DECLINED OPT_INCLUDES);
use Apache::File;

use Fcntl qw(S_IXUSR S_IXGRP);

use strict;

sub handler {
  # Implement "XBitHack full" in a PerlFixupHandler.

  my $r = shift;

  return DECLINED unless
    (-f $r->finfo                    &&    # the file exists
     $r->content_type eq 'text/html' &&    # and is HTML
     $r->allow_options & OPT_INCLUDES);    # and we have Options +Includes

  # Find out the user and group execution status.
  my $mode = (stat _)[2];

  # We have to be user executable specifically.
  return DECLINED unless ($mode & S_IXUSR);
   
  # Set the Last-Modified header if group executable.
  $r->set_last_modified((stat _)[9]) if ($mode & S_IXGRP);

  # Make sure mod_include picks it up.
  $r->handler('server-parsed');

  return OK;
}
1;
