package Cookbook::XMLtoHTML;

use Apache::Constants qw(NOT_FOUND SERVER_ERROR OK);

use XML::LibXML;
use XML::LibXSLT;

use strict;

# We can use the same parsers between requests.
my ($parser, $xslt);

sub handler ($$) {

  my ($class, $r) = @_;

  my ($source, $style_doc, $stylesheet);

  # Initialize the XML and XSLT parser.
  $parser ||= XML::LibXML->new;
  $xslt   ||= XML::LibXSLT->new;

  my $filename = $r->filename;

  # If we receive a .html request change the extension to .xml.
  $filename =~ s/\.html$/.xml/;

  eval { $source = $parser->parse_file($filename) } 
    or return NOT_FOUND;

  # Look for .xsl file for this document.
  # Try document.xsl, then default.xsl in the same directory.
  $filename =~ s/\.xml$/.xsl/;
  $filename =~ s![^/]+$!default.xsl! unless -f $filename;

  eval { $style_doc = $parser->parse_file($filename) } 
    or return NOT_FOUND;

  eval { $stylesheet = $xslt->parse_stylesheet($style_doc) } 
    or return SERVER_ERROR;

  my $results = $stylesheet->transform($source);

  $r->send_http_header('text/html');
  $r->print($stylesheet->output_string($results));

  return OK;
}
1;
