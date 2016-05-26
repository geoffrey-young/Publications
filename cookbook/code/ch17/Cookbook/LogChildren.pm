package Cookbook::LogChildren;

use strict;

my $ChildStartedAt;

sub init_handler {

  $ChildStartedAt = time();

  print STDERR "==> initializing child $$ at ", scalar localtime, "\n";
}

sub exit_handler {

  my $duration = time() - $ChildStartedAt;

  print STDERR "==>      killing child $$ at ", scalar localtime,
               " duration $duration seconds\n";
}
1;
