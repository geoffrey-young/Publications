package My::AuthHandler;

use Apache::Constants qw(OK FORBIDDEN);

use Cookbook::CookieAuthentication;

use strict;

sub handler {

  my $r = Cookbook::CookieAuthentication->new(shift);

  # Let subrequests pass.
  return OK unless $r->is_initial_req;

  # Get the client-supplied credentials.
  my ($status, $password) = $r->get_cookie_auth_pw;

  return $status unless $status == OK;

  # Perform some custom user/password validation.
  return OK if authenticate_user($r->user, $password);

  # Whoops, bad credentials.
  $r->note_cookie_auth_failure;
  return FORBIDDEN;
}

sub authenticate_user {
  # this represents your own, custom authentication routine

  my ($user, $pass) = @_;
  return 1 if $user eq $pass;
}
1;
