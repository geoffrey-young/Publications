package Cookbook::SendAnyDoc;

use Apache::Constants qw(OK NOT_FOUND);
use Apache::File;

use DBI;
use DBD::Oracle;
use MIME::Types qw(by_suffix);
use Time::Piece;

use strict;

sub handler {
  my $r = shift;

  my $user  = $r->dir_config('DBUSER');
  my $pass  = $r->dir_config('DBPASS');
  my $dbase = $r->dir_config('DBASE');

  # Create a Time::Piece object for later.
  my $time = localtime;

  my $dbh = DBI->connect($dbase, $user, $pass,
   {RaiseError => 1, AutoCommit => 1, PrintError => 1}) || die $DBI::errstr;

  # Determine the table and file to match based on the path info.
  # Sample URI: http//localhost/SendAnyDoc/docs/file.pdf
  my ($table, $filename) = $r->path_info =~ m!/(.*)/(.*)!;

  # Create the SQL.
  # This returns the file contents and a last modified time in epoch seconds
  # but relative to the current timezone, unlike Perl's time().
  my $sql= qq(
     select document,
       (last_modified - to_date('01011970','DDMMYYYY')) * 86400
     from $table
     where name = ?
  );

  # Do some DBI specific stuff for BLOB fields.
  $dbh->{LongReadLen} = 10 * 1024 * 1024;  # 10M

  my $sth = $dbh->prepare($sql);

  $sth->execute($filename);

  my ($file, $last_modified) = $sth->fetchrow_array;

  $sth->finish;

  return NOT_FOUND unless $file;

  # Let the browser know we accept range requests.
  $r->headers_out->set('Accept-Ranges' => 'bytes');

  # Set the MIME type based on the document extension.
  $r->content_type(by_suffix($filename)->[0]);

  # Let Apache determine which time is most recent:
  #   either the time from the database; or
  #   the time this package was modified.
  # If using the database time, make sure its GMT.
  (my $package = __PACKAGE__) =~ s!::!/!g;
  $r->update_mtime($last_modified - $time->tzoffset);
  $r->update_mtime((stat $INC{"$package.pm"})[9]);
  $r->set_last_modified;

  # We have to check if it is a range request _after_ setting the Content-Length
  # but _before_ we send the headers, since ap_set_byterange diddles with them.
  # Note that setting the Content-Length is _required_
  $r->set_content_length(length($file));

  my $range_request = $r->set_byterange;

  # Yea or nay.
  if ((my $status = $r->meets_conditions) == OK) {
    $r->send_http_header;
  }
  else {
    return $status;
  }

  # Hold off sending content if they didn't ask for it.
  return OK if $r->header_only;

  # Now, for some byteserving stuff in case it is a PDF document.
  if ($range_request) {
    while( my($offset, $length) = $r->each_byterange) {
      print substr($file, $offset, $length);
    }
  }
  else {
    print $file;
  }

  return OK ;
}
1;
