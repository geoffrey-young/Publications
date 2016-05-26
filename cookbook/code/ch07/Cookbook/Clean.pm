package Cookbook::Clean;

use Apache::Constants qw( OK DECLINED );
use Apache::File;
use Apache::Log;

use HTML::Clean;

use strict;

sub handler {
  
  my $r = shift;

  my $log = $r->server->log;

  unless ($r->content_type eq 'text/html') {
    $log->info("Request is not for an html document - skipping...");
    return DECLINED; 
  }

  my $fh = Apache::File->new($r->filename);

  unless ($fh) {
    $log->warn("Cannot open request - skipping... $!");
    return DECLINED;
  }

  # Slurp the file (hopefully it's not too big).
  my $dirty = do {local $/; <$fh>};

  # Create the new HTML::Clean object.
  my $h = HTML::Clean->new(\$dirty);

  # Set the level of suds.
  $h->level(3);

  # Clean the HTML.
  $h->strip;

  # Send the crisp, clean data.
  $r->send_http_header('text/html');
  print ${$h->data};

  return OK;
}
1;
__END__

=head1 NAME

Cookbook::Clean - Apache content handler that cleans HTML of cruft

=head1 SYNOPSIS

DocumentRoot /usr/local/apache/htdocs

PerlModule Cookbook::Clean
<Directory /usr/local/apache/htdocs>
  SetHandler perl-script
  PerlHandler Cookbook::Clean
</Directory>

=head1 DESCRIPTION

Cleans HTML by "scrubbing the deck" of redundant
whitespace and other useless data.  Basically a
mod_perl interface into HTML::Clean.

=cut
