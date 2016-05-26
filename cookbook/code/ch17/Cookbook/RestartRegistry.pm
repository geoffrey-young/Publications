package Cookbook::RestartRegistry;

use Apache::Constants qw(OK);
use Apache::RegistryLoader;

use DirHandle;

use strict;

sub handler {

  my $rl = Apache::RegistryLoader->new;

  my $dh = DirHandle->new(Apache->server_root_relative('perl-bin')) or die $!;

  foreach my $file ($dh->read) {
    next unless $file =~ m/\.(pl|cgi)$/;

    $rl->handler("/perl-bin/$file",
                 Apache->server_root_relative("perl-bin/$file"));
  }

  return OK;
}
1;
