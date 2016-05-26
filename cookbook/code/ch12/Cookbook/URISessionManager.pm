package Cookbook::URISessionManager;

use Apache::Constants qw(DECLINED OK);
use Apache::URI;

use strict;

sub get_session {
  # Isolate an Apache::Session session from a URL.

  my $r = shift;

  my $uri = $r->parsed_uri;

  # Separate the MD5 session from the real path.
  my ($session, $path) = $uri->path =~ m!^/([a-fA-F0-9]{32})(/.*)!;
  
  return DECLINED unless $session;

  # Now, put the session in a note...
  $r->notes(SESSION => $session);

  # ... and set the URI to the proper path.
  $r->uri($path);

  return DECLINED;
}

sub clean_uri {
  # Jump to the specified URL so that the Referer header
  # does not leak to other sites.

  my $r = shift;

  my ($uri) = $r->uri =~ m!.*(http://.*)!;

  $r->send_http_header('text/html');

  print<<EOF;
<html>
  <head>
    <meta http-equiv="refresh" content="0;URL=$uri">
  </head>
  <body>
    you should be going <a href="$uri">here</a> soon
  </body>
</html>
EOF

  return OK;
}
1;
