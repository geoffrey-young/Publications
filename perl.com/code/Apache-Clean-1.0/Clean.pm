package Apache::Clean;

use Apache::Log ();

use Apache::Constants qw(OK DECLINED);

use Apache::Filter ();

use HTML::Clean ();

use strict;

sub handler {

  my $r   = shift;

  $r      = $r->filter_register;

  my $log = $r->server->log;

  # open a filehandle on data from previous filters in the chain,
  # or $r->filename if we're the first filter
  my ($fh, $status) = $r->filter_input;
    
  return $status unless $status == OK;

  # we only process HTML documents
  unless ($r->content_type =~ m!text/html!i) {
    $log->info('skipping request to ', $r->uri, ' (not an HTML document)');

    # we can't ever return DECLINED when using Apache::Filter - we need
    # to actually send the (unaltered) content along to the next filter

    $r->send_http_header();

    print while <$fh>;

    return OK;
  }

  # parse the configuration options
  my $level = $r->dir_config->get('CleanLevel') || 1;

  my %options = map { $_ => 1 } $r->dir_config->get('CleanOption');

  # now, filter the content
  my $dirty = do { local $/; <$fh> };

  my $h = HTML::Clean->new(\$dirty);

  $h->level($level);

  $h->strip(\%options);

  $r->send_http_header();

  $r->print(${$h->data});

  return OK;
}

1;
 
__END__

=head1 NAME 

Apache::Clean - interface into HTML::Clean for mod_perl

=head1 SYNOPSIS

httpd.conf:

  PerlModule Apache::Filter
  PerlModule Apache::Clean

  Alias /clean /usr/local/apache/htdocs
  <Location /clean>
    SetHandler perl-script
    PerlHandler Apache::Clean

    PerlSetVar CleanOption shortertags
    PerlAddVar CleanOption whitespace
  </Location>

=head1 DESCRIPTION

Apache::Clean uses HTML::Clean to tidy up large, messy HTML, saving
bandwidth. 

Only documents with a content type of "text/html" are affected - all
others are passed through unaltered.

=head1 OPTIONS

Apache::Clean supports few options - all of which are based on
options from HTML::Clean.  Apache::Clean will only tidy up whitespace 
(via $h->strip) and will not perform other options of HTML::Clean
(such as browser compatibility).  See the HTML::Clean manpage for 
details.

=over 4

=item CleanLevel

sets the clean level, which is passed to the level() method
in HTML::Clean.

  PerlSetVar CleanLevel 9

CleanLevel defaults to 1.

=item CleanOption

specifies the set of options which are passed to the options()
method in HTML::Clean - see the HTML::Clean manpage for a complete
list of options.

  PerlSetVar CleanOption shortertags
  PerlAddVar CleanOption whitespace

CleanOption has no default.

=back

=head1 NOTES

This is alpha software, and as such has not been tested on multiple
platforms or environments.

=head1 FEATURES/BUGS

probably lots

=head1 SEE ALSO

perl(1), mod_perl(3), Apache(3), HTML::Clean(3), Apache::Filter(3)

=head1 AUTHOR

Geoffrey Young <geoff@modperlcookbook.org>

=head1 COPYRIGHT

Copyright (c) 2003, Geoffrey Young
All rights reserved.

This module is free software.  It may be used, redistributed
and/or modified under the same terms as Perl itself.

=head1 HISTORY

This code is derived from the Cookbook::Clean and
Cookbook::TestMe modules available as part of
"The mod_perl Developer's Cookbook".

For more information, visit http://www.modperlcookbook.org/

=cut
