#!/usr/bin/perl

BEGIN {
  $ENV{'ORACLE_HOME'} = "/u01/app/oracle/product/8.1.6";
  $ENV{'ORACLE_SID'}  = "HELM";
  use lib qw(/home/www/lib);
}

#---------------------------------------------------------------------
# pre-load frequently used modules
#---------------------------------------------------------------------
use Apache::DBI;
use Apache::Registry;
use Apache::RegistryLoader;

use DBI;
use DBD::Oracle;
use DirHandle;

use strict;

#---------------------------------------------------------------------
# enable script sharing across vhosts
#---------------------------------------------------------------------
$Apache::Registry::NameWithVirtualHost = 0; 

#---------------------------------------------------------------------
# pre-load registry scripts
#---------------------------------------------------------------------
my $rl = Apache::RegistryLoader->new;

my $dh = DirHandle->new("/usr/local/apache/perl-bin") || die $!;

foreach my $file ($dh->read) {
  next unless $file =~ m/\.pl$|\.cgi$/;
  print STDOUT "pre-loading $file\n";

  $rl->handler("/perl-bin/$file", 
               "/usr/local/apache/perl-bin/$file");
}

#---------------------------------------------------------------------
# open db connections
#---------------------------------------------------------------------
my $dbh = Apache::DBI->connect_on_init('dbi:Oracle:HELM', 
                                       'user', 
                                       'password',
                                       { RaiseError => 1, 
                                         AutoCommit => 1, 
                                         PrintError => 1 }) 
          || die $DBI::errstr;

# remember to always return true
1;
