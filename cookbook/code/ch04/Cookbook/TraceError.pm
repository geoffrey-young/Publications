package Cookbook::TraceError;

use Apache::Constants qw(OK SERVER_ERROR DECLINED);
use Apache::Log;

use strict;

sub handler {
  # Enable all debugging stuff and re-run (most of) the request.
  # Use in a PerlCleanupHandler.

  my $r = shift;

  # Don't do anything unless the main process errors.
  return DECLINED unless $r->is_initial_req &&
                         $r->status == SERVER_ERROR;

  # Get the old LogLevel while setting the new value
  my $old_loglevel = $r->server->loglevel(Apache::Log::DEBUG);

  # Set some other trace routines.
  my $old_trace = DBI->trace(2);

  # Start the debuggging request.
  my $sub = $r->lookup_uri($r->uri);

  # run() would ordinarily send content to the client, but
  # since we're in cleanup, the connection is already closed.
  $sub->run;

  # Reset things back to their original state - 
  # loglevel(N) will persist for the lifetime of the child process.
  DBI->trace($old_trace);
  $r->server->loglevel($old_loglevel);

  return OK;
}
1;
