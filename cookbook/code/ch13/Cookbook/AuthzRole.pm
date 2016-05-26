package Cookbook::AuthzRole;

use Apache::Constants qw(OK AUTH_REQUIRED);

use DBI;

use strict;

sub handler {

  my $r = shift;

  my $dbuser = $r->dir_config('DBUSER');
  my $dbpass = $r->dir_config('DBPASS');
  my $dbase  = $r->dir_config('DBASE');

  # Balk if we don't have a user to check.
  my $user = $r->user
    or $r->note_basic_auth_failure && return AUTH_REQUIRED;

  foreach my $requires (@{$r->requires}) {
    my ($directive, @list) = split " ", $requires->{requirement};

    # We're ok if only valid-user was required.
    return OK if lc($directive) eq 'valid-user';

    # Likewise if the user requirement was specified and
    # we match based on what we already know.
    return OK if lc($directive) eq 'user' && grep { $_ eq $user } @list;

    # Now for the real work - authorize the user based on Oracle role.
    # This would cover an httpd.conf entry like:
    # Require group DBA
    if ($directive eq 'group') {
      my $dbh = DBI->connect($dbase, $dbuser, $dbpass,
        {RaiseError => 1, PrintError => 1}) or die $DBI::errstr;
 
      my $sql= qq(
         select grantee
           from dba_role_privs
           where grantee = UPPER(?)
           and   granted_role = UPPER(?)
      );

      my $sth = $dbh->prepare($sql);

      foreach my $role (@list) {
        $sth->execute($r->user, $role);

        my ($ok)  = $sth->fetchrow_array;

        $sth->finish;

        return OK if $ok;
      }
    }
  }

  # No criteria was met so the user didn't pass.
  $r->note_basic_auth_failure;
  return AUTH_REQUIRED;
}
1;
