package Cookbook::SimpleStat;

use Apache::Constants qw(OK);

use strict;

# Create global hash to hold the modification times of the modules.
my %stat = ();

sub handler {

  my $r = shift;

  # Loop through %INC and reload each file.
  foreach my $key (keys %INC) {

    # Get the modification time of the file.
    my $file = $INC{$key};
    my $mtime = (stat $file)[9];

    next unless defined $mtime && $mtime;

    # Default to the time _this_ module was loaded (roughly server startup).
    $stat{$file} = $^T unless defined $stat{$file};

    if ( $mtime > $stat{$file} ) {
      local $^W;  # turn off warnings for this bit...

      # Reload the file.
      delete $INC{$key};
      eval { require $file };

      $r->server->log->warn("$file failed reload in pid $$! $@") if $@;

      # Store the new load time.
      $stat{$file} = $mtime;
    }
  }

  return OK;
}
1;
