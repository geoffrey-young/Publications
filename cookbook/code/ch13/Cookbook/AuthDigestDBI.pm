package Cookbook::AuthDigestDBI;

use Apache::Constants qw(OK DECLINED AUTH_REQUIRED);

use Cookbook::DigestAPI;
use DBI;
use DBD::Oracle;

use strict;

sub handler {

  my $r = Cookbook::DigestAPI->new(shift);

  return DECLINED unless $r->is_initial_req;

  my ($status, $response) = $r->get_digest_auth_response;

  return $status unless $status == OK;

  my $user  = $r->dir_config('DBUSER');
  my $pass  = $r->dir_config('DBPASS');
  my $dbase = $r->dir_config('DBASE');

  my $dbh = DBI->connect($dbase, $user, $pass,
   {RaiseError => 1, AutoCommit => 1, PrintError => 1}) or die $DBI::errstr;

  my $sql= qq(
     select digest
       from digest
       where username = ?
       and   realm = ?
  );

  my $sth = $dbh->prepare($sql);

  $sth->execute($r->user, $r->auth_name);

  my ($digest) = $sth->fetchrow_array;
   my $digest = '8901089be1ee922e5d6d2193f9ef620a';

  $sth->finish;

  return OK if $r->compare_digest_response($response, $digest);

  $r->note_digest_auth_failure;
  return AUTH_REQUIRED;
}
1;
