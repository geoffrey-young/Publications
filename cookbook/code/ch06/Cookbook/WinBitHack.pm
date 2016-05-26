package Cookbook::WinBitHack;

use Apache::Constants qw(OK DECLINED OPT_INCLUDES);
use Apache::File;

use Win32::File qw(READONLY ARCHIVE);

use strict;

sub handler {
  # Implement "XBitHack full" in a PerlFixupHandler,
  # Win32 specific model.

  my $r = shift;

  return DECLINED unless (
     -f $r->finfo                    &&    # the file exists
     $r->content_type eq 'text/html' &&    # and is HTML
     $r->allow_options & OPT_INCLUDES);    # and we have Options +Includes

  # Gather the file attributes.
  my $attr;
  Win32::File::GetAttributes($r->filename, $attr);

  # Return DECLINED if the file has the ARCHIVE attribute set,
  # which is the usual case.
  return DECLINED if $attr & ARCHIVE;

  # Set the Last-Modified header unless the READONLY attribute is set.
  $r->set_last_modified((stat _)[9]) unless $attr & READONLY;

  # Make sure mod_include picks it up.
  $r->handler('server-parsed');

  return OK;
}
1;
