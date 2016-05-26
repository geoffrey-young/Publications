package Cookbook::ViewServer;

use Apache::Constants qw(OK);
use Apache::Log;

use strict;

sub handler {

  # Get the Apache request object...
  my $r = shift;

  # ... and the Apache::Server object for this request.
  my $s = $r->server;

  $r->send_http_header('text/plain');

  # Iterate through all the configured servers.
  for (my $s = Apache->server; $s; $s = $s->next) {
    print "User directive:        ", $s->uid,             "\n";
    print "Group directive:       ", $s->gid,             "\n";
    print "Port directive:        ", $s->port,            "\n";
    print "TimeOut directive:     ", $s->timeout,         "\n";
    print "ErrorLog directive:    ", $s->error_fname,     "\n";
    print "LogLevel directive:    ", $s->loglevel,        "\n";
    print "ServerName directive:  ", $s->server_hostname, "\n";
    print "ServerAdmin directive: ", $s->server_admin,    "\n";

    print "ServerAlias directives:\n" if $s->is_virtual;
    print "\t$_\n" foreach @{$s->names};
    print "-" x 30,                                       "\n";
  }

  return OK;
}
1;
