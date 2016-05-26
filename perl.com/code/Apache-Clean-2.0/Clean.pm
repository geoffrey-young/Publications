package Apache::Clean;

use 5.008;

use Apache::Filter ();      # $f
use Apache::RequestRec ();  # $r
use Apache::RequestUtil (); # $r->dir_config()
use Apache::Log ();         # $log->info()
use APR::Table ();          # dir_config->get() and headers_out->get()

use Apache::Const -compile => qw(OK DECLINED);

use HTML::Clean ();

use strict;

sub handler {

  my $f   = shift;

  my $r   = $f->r;

  my $log = $r->server->log;

  # we only process HTML documents
  unless ($r->content_type =~ m!text/html!i) {
    $log->info('skipping request to ', $r->uri, ' (not an HTML document)');

    return Apache::DECLINED;
  }

  my $context;

  unless ($f->ctx) {
    # these are things we only want to do once no matter how
    # many times our filter is invoked per request

    # parse the configuration options
    my $level = $r->dir_config->get('CleanLevel') || 1;

    my %options = map { $_ => 1 } $r->dir_config->get('CleanOption');

    # store the configuration
    $context = { level   => $level,
                 options => \%options,
                 extra   => undef };

    # output filters that alter content are responsible for removing
    # the Content-Length header, but we only need to do this once.
    $r->headers_out->unset('Content-Length');
  }

  # retrieve the filter context, which was set up on the first invocation
  $context ||= $f->ctx;

  # now, filter the content
  while ($f->read(my $buffer, 1024)) {

    # prepend any tags leftover from the last buffer or invocation
    $buffer = $context->{extra} . $buffer if $context->{extra};

    # if our buffer ends in a split tag ('<strong' for example)
    # save processing the tag for later
    if (($context->{extra}) = $buffer =~ m/(<[^>]*)$/) {
      $buffer = substr($buffer, 0, - length($context->{extra}));
    }

    my $h = HTML::Clean->new(\$buffer);

    $h->level($context->{level});

    $h->strip($context->{options});

    $f->print(${$h->data});
  }

  if ($f->seen_eos) {
    # we've seen the end of the data stream

    # print any leftover data
    $f->print($context->{extra}) if $context->{extra};
  }
  else {
    # there's more data to come

    # store the filter context, including any leftover data
    # in the 'extra' key
    $f->ctx($context);
  }

  return Apache::OK;
}

1;
 
__END__

=head1 NAME 

Apache::Clean - interface into HTML::Clean for mod_perl 2.0

=head1 SYNOPSIS

httpd.conf:

  PerlModule Apache::Clean

  Alias /clean /usr/local/apache2/htdocs
  <Location /clean>
    PerlOutputFilterHandler Apache::Clean

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

probably lots - this is the preliminary port to mod_perl 2.0

=head1 SEE ALSO

perl(1), mod_perl(3), Apache(3), HTML::Clean(3)

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
