package Cookbook::Authenticate;

use Apache::Constants qw(REDIRECT);
use Apache::AuthCookie;

use Cookbook::Utils qw(authenticate_user authenticate_session);

use strict;

@Cookbook::Authenticate::ISA = qw(Apache::AuthCookie);

sub authen_cred {
  # Do what is needed to authenticate the supplied credentials
  # and return a session key, or undef on failure.

  my ($self, $r, $user, $password) = @_;

  my $session = authenticate_user($user, $password);

  return $session;
}

sub authen_ses_key {
  # Do what is needed to authenticate the session key,
  # and return the user name if it checks, or undef.

  my ($self, $r, $session) = @_;

  my $user = authenticate_session($session);

  return $user;
}

sub logout ($$) {
  # Call Apache::AuthCookie::logout() to make sure that we get
  # rid of all the credentials, then redirect to a friendly page.

  my ($self, $r) = @_;

  $self->SUPER::logout($r);

  $r->headers_out->set(Location => '/logged-out.html');

  return REDIRECT;
}
1;
