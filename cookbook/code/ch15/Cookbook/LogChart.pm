package Cookbook::LogChart;

use Apache::Constants qw(OK SERVER_ERROR);

use DBI;
use GD::Graph::bars;

use strict;

sub handler {
  # Look up statistics from a database driven access log for
  # a particular date, and present a bar graph for hits on
  # an hourly basis.

  my $r = shift;

  # Get the desired date.
  (my $date = $r->path_info) =~ s!^/!!;

  # Do some minimal checking.
  unless ($date =~ m/\d{4}-\d{2}-\d{2}/) {
    $r->log_error('Date must be in form YYYY-MM-DD');
    return SERVER_ERROR;
  }

  my $user  = $r->dir_config('DBUSER');
  my $pass  = $r->dir_config('DBPASS');
  my $dbase = $r->dir_config('DBASE');

  # Extract the data.  This assumes a PerlLogHandler
  # similar to that from Recipe 16.1 is installed.
  my $dbh = DBI->connect($dbase, $user, $pass,
   {RaiseError => 1, AutoCommit => 1, PrintError => 1}) or die $DBI::errstr;

  # GD::Graph expects sequential x values.
  my $sql= qq(
    select to_char(servedate, 'HH24') hour, count(*) total
      from sitelog
      where trunc(servedate) = to_date(?, 'YYYY-MM-DD')
      group by to_char(servedate, 'HH24')
      order by hour
  );

  my $sth = $dbh->prepare($sql);

  $sth->execute($date);

  my $rows = $sth->fetchall_arrayref;

  # Set up the data.
  my ($x, $y);

  foreach my $row (@$rows) {
    push @$x, @$row[0];
    push @$y, @$row[1];
  }

  # Create the GD::Graph object...
  my $graph = GD::Graph::bars->new;

  # ... and set the title and legends.
  $graph->set(x_label          => 'Hour',
              y_label          => 'Hits',
              title            => "Accesses for $date",
              bar_spacing      => 4,
              x_label_position => 0.5,
             );

  # Plot the data.
  my @data = ($x, $y);
  unless ($graph->plot(\@data)) {
    $r->warn($graph->error);
    return SERVER_ERROR;
  }

  # Finally, send it to the browser with the right header.
  $r->send_http_header('image/png');

  binmode STDOUT;    # very important for Win32

  $r->print($graph->gd->png);

  return OK;
}
1;
