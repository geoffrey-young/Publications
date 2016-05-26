package Custom::RefBlock;

use Apache::Constants qw(OK);

use strict;

sub handler {
  # use as a PerlInitHandler to override the settings in
  # httpd.conf if coming from a local IP
  # RefBlockDebug is a FLAG field, so valid values are 0 (Off) and 1 (On)

  my $r = shift;

  if ($r->connection->remote_ip =~ m/^10.3.4/) {
    # dig out the configuration data
    my $cfg = Apache::ModuleConfig->get($r, 'Apache::RefererBlock');

    # do a bit of swapping to set the new value and preserve the old
    (my $old_debug, $cfg->{debug}) = ($cfg->{debug}, 1);

    # make sure that this child is reset
    $r->push_handlers(PerlCleanupHandler =>
                      sub { $cfg->{debug} = $old_debug });
  }

  return OK;
}
1;
