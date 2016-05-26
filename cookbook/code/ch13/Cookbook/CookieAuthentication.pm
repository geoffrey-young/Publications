package Cookbook::CookieAuthentication;

use Apache::Constants qw(OK REDIRECT SERVER_ERROR DECLINED FORBIDDEN);
use Apache::Cookie;
use Apache::Request;

use MIME::Base64 qw(encode_base64 decode_base64);

use strict;

@Cookbook::CookieAuthentication::ISA = qw(Apache::Request);

sub new {

  my ($class, $r) = @_;

  $r = Apache::Request->new($r);

  return bless {r => $r}, $class;
}

sub get_cookie_auth_pw {

  my $r = shift;

  my $log = $r->server->log;

  my $auth_type = $r->auth_type;
  my $auth_name = $r->auth_name;

  # Check that the custom login form was specified.
  my $login = $r->dir_config('CookieLogin');

  unless ($login) {
    $log->error("Must specify a login form");
    return SERVER_ERROR;
  }

  # Setup FORBIDDEN response to point to our login form.
  $r->custom_response(FORBIDDEN, $login);
 
  # Check that we're supposed to be handling this.
  unless (lc($auth_type) eq 'cookie') {
    $log->info("AuthType $auth_type not supported by ", ref($r));
    return DECLINED;
  }

  # Check that AuthName was set.
  unless ($auth_name) {
    $log->error("AuthName not set");
    return SERVER_ERROR;
  }

  # Try to get the authentication cookie.
  my %cookiejar = Apache::Cookie->new($r)->parse;

  unless ($cookiejar{$auth_name}) {
    $r->note_cookie_auth_failure;
    return FORBIDDEN;
  }

  # Get the username and password from the cookie.
  my %auth_cookie = $cookiejar{$auth_name}->value;

  my ($user, $password) = split /:/, decode_base64($auth_cookie{Basic}), 2;

  unless ($user && $password) {
    # Whoops, cookie came back without user credentials.

    # Ok, see if we got any credentials from a login form.
    $user = $r->param('user');
    $password = $r->param('password');

    # Don't overwrite the URI in the old cookie, just return.
    return FORBIDDEN unless ($user && $password);

    # We have some credientials, so set an authorization cookie.
    my @values = (uri => $auth_cookie{uri},
                  Basic => encode_base64(join ":", ($user,$password)),
                 );

    $cookiejar{$auth_name}->value(\@values);
    $cookiejar{$auth_name}->path('/');

    $cookiejar{$auth_name}->bake;

    # Now redirect back to where the user was headed
    # and start the cycle again.
    $r->headers_out->set(Location => $auth_cookie{uri});
    return REDIRECT;
  }

  # Ok, we must have received a proper cookie,
  # so pass the info back.
  $r->user($user);
  $r->connection->auth_type($auth_type);

  return (OK, $password);
}

sub note_cookie_auth_failure {

  my $r = shift;

  my $auth_cookie = Apache::Cookie->new($r,
                                        -name => $r->auth_name,
                                        -value => { uri => $r->uri },
                                        -path => '/'
                                       );
  $auth_cookie->bake;
}
1;
