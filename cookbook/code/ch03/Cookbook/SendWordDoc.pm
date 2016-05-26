package Cookbook::SendWordDoc;

use Apache::Constants qw( OK NOT_FOUND );
use DBI;
use DBD::Oracle;

use strict;

sub handler {
  my $r = shift;

  my $user  = $r->dir_config('DBUSER');
  my $pass  = $r->dir_config('DBPASS');
  my $dbase = $r->dir_config('DBASE');

  my $dbh = DBI->connect($dbase, $user, $pass,
   {RaiseError => 1, AutoCommit => 1, PrintError => 1}) or die $DBI::errstr;

  my $sql= qq(
     select document from worddocs
       where name = ?
  );

  # determine the filename the user wants to retrieve
  my ($filename) = $r->path_info =~ m!/(.*)!;

  # do some DBI specific stuff for BLOB fields
  $dbh->{LongReadLen} = 300 * 1024;  # 300K

  my $sth = $dbh->prepare($sql);

  $sth->execute($filename);

  my $file = $sth->fetchrow;

  $sth->finish;

  return NOT_FOUND unless $file;

  $r->headers_out->set('Content-Disposition' => ' inline; filename=$filename');
  $r->send_http_header('application/msword');

  print $file;

  return OK ;
}

1;
