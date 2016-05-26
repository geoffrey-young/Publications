package Cookbook::DigestAPI;

use Apache;
use Apache::Constants qw(OK DECLINED SERVER_ERROR AUTH_REQUIRED);

use 5.006;
use Digest::MD5;
use DynaLoader;

use strict;

our @ISA = qw(DynaLoader Apache);
our $VERSION = '0.01';

__PACKAGE__->bootstrap($VERSION);

sub new {

  my ($class, $r) = @_;

  $r ||= Apache->request;

  return bless { r => $r }, $class;
}

sub get_digest_auth_response {

  my $r = shift;

  my $auth_type = $r->auth_type;
  my $auth_name = $r->auth_name;

  # Check that we're supposed to be handling this.
  unless (lc($auth_type) eq 'digest') {
    $r->log->info("AuthType $auth_type not supported by ", ref($r));
    return DECLINED;
  }

  # Check that AuthName was set.
  unless ($auth_name) {
    $r->log->error("AuthName not set");
    return SERVER_ERROR;
  }

  # Get the response to the Digest challenge.
  my $auth_header = $r->headers_in->get($r->proxyreq ? 
                                        'Proxy-Authorization' :
                                        'Authorization');

  # We issued a Digest challenge - make sure we got Digest back.
  $r->note_digest_auth_failure && return AUTH_REQUIRED
    unless $auth_header =~ m/^Digest/;
  
  # Parse the response header into a hash.
  $auth_header =~ s/^Digest\s+//;
  $auth_header =~ s/"//g;

  my %response = map { split(/=/) } split(/,\s*/, $auth_header);

  # Make sure that the response contained all the right info.
  foreach my $key (qw(username realm nonce uri response)) {
    $r->note_digest_auth_failure && return AUTH_REQUIRED 
      unless $response{$key};
  }

  # Ok, we're good to go. Set some info for the request
  # and return the response information so it can be checked.
  $r->user($response{username});
  $r->connection->auth_type('Digest');

  return (OK, \%response);
}

sub compare_digest_response {
  # Compare a response hash from get_digest_auth_response()
  # against a pre-calculated digest (e.g., a3165385201a7ba52a12e88cb606bc76).

  my ($r, $response, $digest) = @_;

  my $md5 = Digest::MD5->new;

  $md5->add(join ":", ($r->method, $response->{uri}));

  $md5->add(join ":", ($digest, $response->{nonce}, $md5->hexdigest));

  return $response->{response} eq $md5->hexdigest;
}
1;
