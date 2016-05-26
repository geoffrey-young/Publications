package Cookbook::MaintWindow;

use Cookbook::PerlDispatchHandlerHelper qw(call_handler);

use strict;

sub handler {

  my ($r, $handler) = @_;

  # Run a specific content handler during
  # the 1-2am maintenance window.

  if ($r->current_callback eq 'PerlHandler' && (localtime)[2] == 1) {
     # Call a specific handler.
     return call_handler($r, 'Cookbook::MaintWindow::down');
  }

  # Otherwise, run the regularly scheduled handler.
  return call_handler($r, $handler);
}

sub down {

  shift->send_http_header('text/plain');

  print <<EOF;
Sorry, this site is offline from 1 to 2 AM (local time) 
for regularly scheduled maintenance
EOF
}
1;
