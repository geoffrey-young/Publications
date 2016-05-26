package Cookbook::RSS;

use Apache::Constants qw(OK DECLINED);

use XML::RSS;

use strict;

sub handler {

  my $r = shift;

  my $filename = $r->filename;

  return DECLINED unless $filename =~ m/\.rss$/;

  my $rss = XML::RSS->new;

  if (-f $filename) {
    # Read RDF file from disk.
    $rss->parsefile($filename);
  } 
  else {
    # No such rdf file, so create a base channel.
    $rss->channel(title       => 'mod_perl Cookbook',
                  link        => 'http://www.modperlcookbook.org/',
                  description => 'The source of mod_perl recipes',
                 );
  }

  $rss->add_item(title       => 'mod_perl resources',
                 link        => 'http://www.modperlcookbook.org/resources/',
                 description => 'More resources &amp; tips for your mod_perl life',
                );

  $rss->add_item(title       => 'Sample Recipes',
                 link        => 'http://www.modperlcookbook.org/code/',
                 description => 'Sample mod_perl recipes',
                );

  $r->send_http_header('text/xml');
  $r->print($rss->as_string, "\n");

  return OK;
}
1;
