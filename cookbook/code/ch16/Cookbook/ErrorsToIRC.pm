package Cookbook::ErrorsToIRC;

use Apache::Constants qw(OK);
use Apache::File;

use Cookbook::DivertErrorLog qw(set_error_log restore_error_log);

use Net::IRC ();
use Sys::Hostname ();

our ($irc, $host);

use strict;

sub handler {

  my $r = shift;

  # Create a temporary file for holding the errors for this request.
  my $fh = Apache::File->tmpfile;

  # Store away the filehandle for later.
  $r->pnotes(ERROR_HANDLE => $fh);

  # Push our log routine if we can divert the error_log to our file.
  $r->register_cleanup(\&send_to_irc) if set_error_log($fh);

  return OK;
}

sub send_to_irc {

  my $r = shift;

  my $irc_host = $r->dir_config('IRCHost') || 'localhost';

  $irc  ||= Net::IRC->new();
  $host ||= Sys::Hostname::hostname();

  # Restore the original error_log.
  # We do this so that the true Apache error_log captures
  # any errors from our processing here.
  my $error_log = restore_error_log;

  # Get the error filehandle we created earlier.
  my $fh = $r->pnotes('ERROR_HANDLE');

  seek($fh, 0, 0); # rewind

  # Open an IRC connection and send the diverted
  # error log across.  This is all pretty standard
  # Net::IRC stuff.
  my $conn = $irc->newconn(Nick    => "log-$$",
                           Server  => $irc_host,
                           Port    =>  6667,
                           Ircname => "Apache Log Bot $$ on $host");
  $conn->add_global_handler('376', \&on_connect);
  $irc->do_one_loop;

  $conn->privmsg('#logs', ('error_log for', $r->uri));

  while (my $line = <$fh>) {
    $conn->privmsg('#logs', $line);
  }

  $conn->quit();

  return OK;
}

sub on_connect {
  # Callback for the Net::IRC object.

  my $self = shift;

  $self->join('#logs');
}
1;
