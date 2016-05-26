package Cookbook::DBIUtils;

use strict;

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(dbh_terminate);

sub dbh_terminate {
  # Subroutine based on the connect() methods of Apache::DBI and DBI.
  # The idea is to get the id of the connection and remove it from
  # the pool of cached connections.

  # Ok, this part is stolen right from DBI->connect().
  # Remember that Apache::DBI->connect() is never called directly - it 
  # receives its arguments from DBI.pm.  So we have to regenerate
  # the connect string eventually received by Apache::DBI.
  my $arg = shift;
  $arg =~ s/^dbi:\w*?(?:\((.*?)\))?://i
    or '' =~ /()/;
  my $driver_attrib_spec = $1;
  unshift @_, $arg;
  
  my @args = map { defined $_ ? $_ : "" } @_;

  $driver_attrib_spec = { split /\s*=>?\s*|\s*,\s*/, $driver_attrib_spec }
    if $driver_attrib_spec;

  my $attr = {
	      PrintError=>1, AutoCommit=>1,
	      ref $args[3] ? %{$args[3]} : (),
	      ref $driver_attrib_spec ? %$driver_attrib_spec : (),
	     };

  # Now we are in Apache::DBI->connect(), where we can generated
  # the key Apache::DBI associates with the current connection.
  my $Idx = join $;, $args[0], $args[1], $args[2];
  
  while (my ($key,$val) = each %{$attr}) {
    $Idx .= "$;$key=$val";
  }
  
  # Once we have the ID of the connection, we can retrieve the
  # internal hash that Apache::DBI uses to hold the connections.
  my $handlers = Apache::DBI->all_handlers;
  
  my $r = Apache->request;

  if ($handlers->{$Idx}) {
    $r->warn("About to terminate the connection...");
    
    unless (delete $handlers->{$Idx}) {
      $r->log_error("Could not terminate connection $Idx");
      return;
    }
  }
  else {
    $r->log_error("Could not find the connection $Idx");
    return;
  }

  return 1;
}
1;
