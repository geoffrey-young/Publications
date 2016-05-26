package Cookbook::DefaultLogin;

use Apache::Constants qw(OK DECLINED);

use MIME::Base64 ();
use Socket qw(sockaddr_in inet_ntoa);

use strict;

sub handler {

  my $r = shift;

  my $c = $r->connection;

  # Parse the header ourselves.
  my $auth_header = $r->headers_in->get('Authorization');
  my $credentials = (split / /, $auth_header)[-1];

  my ($user, $passwd) = split /:/, MIME::Base64::decode($credentials), 2;

  # Make sure usernames are lowercase.
  $user = lc($user);

  # Automatic login for the user 'guest', or localhost.
  my $local_ip = inet_ntoa((sockaddr_in($c->local_addr))[1]);

  if ($user eq 'guest' || $c->remote_ip eq $local_ip) {
    $user   = $r->dir_config->get('DefaultUser');
    $passwd = $r->dir_config->get('DefaultPassword');
  }

  return DECLINED unless $user;  # nothing to do...

  # Re-join user and password and set the incoming header.
  $credentials = MIME::Base64::encode(join(':', $user, $passwd));

  $r->headers_in->set(Authorization => "Basic $credentials");

  return OK;
}
1;
