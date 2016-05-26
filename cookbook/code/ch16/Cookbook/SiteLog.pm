package Cookbook::SiteLog;

use Apache::Constants qw(OK); 

use DBI;
use Time::HiRes qw(time);

use strict;

sub handler {

  my $r = shift;

  my $user  = $r->dir_config('DBUSER');
  my $pass  = $r->dir_config('DBPASS');
  my $dbase = $r->dir_config('DBASE');

  my $dbh = DBI->connect($dbase, $user, $pass,
   {RaiseError => 1, AutoCommit => 1, PrintError => 1}) or die $DBI::errstr;

  # Gather the per-request data and put it into a hash.
  my %columns = ();

  $columns{waittime}   = time - $r->pnotes("REQUEST_START");
  $columns{status}     = $r->status;
  $columns{bytes}      = $r->bytes_sent;
  $columns{browser}    = $r->headers_in->get('User-agent');
  $columns{filename}   = $r->filename;
  $columns{uri}        = $r->uri;
  $columns{referer}    = $r->headers_in->get('Referer');
  $columns{remotehost} = $r->get_remote_host;
  $columns{remoteip}   = $r->connection->remote_ip;
  $columns{remoteuser} = $r->user;
  $columns{hostname}   = $r->get_server_name;
  $columns{encoding}   = $r->headers_in->get('Accept-Encoding');
  $columns{language}   = $r->headers_in->get('Accept-Language');
  $columns{pid}        = $$;

  # Create the SQL
  my $fields = join "$_,", keys %columns;
  my $values = join ', ', ('?') x values %columns;

  my $sql = qq(
    insert into www.sitelog (hit, servedate, $fields)
    values (hitsequence.nextval, sysdate, $values)
  );

  my $sth = $dbh->prepare($sql);

  $sth->execute(values %columns);

  $dbh->disconnect;

  return OK;
}
1;
__END__
Here is some SQL that works for Oracle

CREATE TABLE WWW.SITELOG (
  HIT        NUMBER(20), 
  SERVEDATE  DATE, 
  WAITTIME   NUMBER(10,2), 
  STATUS     NUMBER(3), 
  BYTES      NUMBER(10), 
  BROWSER    VARCHAR2(80), 
  FILENAME   VARCHAR2(150), 
  URL        VARCHAR2(150), 
  REFERER    VARCHAR2(150), 
  REMOTEHOST VARCHAR2(80), 
  REMOTEIP   VARCHAR2(15), 
  REMOTEUSER VARCHAR2(30),
  HOSTNAME   VARCHAR2(80), 
  ENCODING   VARCHAR2(50), 
  LANGUAGE   VARCHAR2(30), 
  PID        NUMBER(10)
)

CREATE SEQUENCE WWW.HITSEQUENCE 
  INCREMENT BY 1 
  START WITH 1 
  MAXVALUE 1.0E28 
  MINVALUE 1 
  NOCYCLE 
  CACHE 20 
  ORDER
