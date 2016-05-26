package My::Authenticate;

use Apache::Constants qw(OK DECLINED AUTH_REQUIRED);

use strict;

sub handler {

  my $r = shift;

  # Let subrequests pass.
  return DECLINED unless $r->is_initial_req;

  # Get the client-supplied credentials.
  my ($status, $password) = $r->get_basic_auth_pw;

  return $status unless $status == OK;

  # Perform some custom user/password validation.
  return OK if authenticate_user($r->user, $password);

  # Whoops, bad credentials.
  $r->note_basic_auth_failure;
  return AUTH_REQUIRED;
}

sub authenticate_user {
  # this represents your own, custom authentication routine

  my ($user, $pass) = @_;
  return 1 if $user eq $pass;
}
1;
