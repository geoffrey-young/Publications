package Cookbook::SSI;

use Apache::SSI;

use HTTP::Request;
use LWP::UserAgent;

use strict;

@Cookbook::SSI::ISA = qw(Apache::SSI);

sub ssi_include {
  # Re-implement the 'include' SSI tag so that its output
  # can be filtered using Apache::Filter.
  # We only handle <!--#include virtual="file"--> tags for now.

  my ($self, $args) = @_;

  return $self->error("Include must be of type 'virtual'")
    unless $args->{virtual};

  # Create a self-referential URI.
  my $uri = Apache::URI->parse(Apache->request);

  # Now, add the URI path based on the SSI tag.
  if ($args->{virtual} =~ m!^/!) {
    # Path is absolute.
    $uri->path($args->{virtual});
  }
  else {
    # Path is relative to current document.
    my ($base) = $uri->path =~ m!(.*/)!;

    $uri->path($base . $args->{virtual});
  }

  my $request = HTTP::Request->new(GET => $uri->unparse);

  my $response = LWP::UserAgent->new->request($request);

  return $self->error("Could not Include virtual URL");
    unless $response->is_success;

  # Return the content of the request back to Apache::SSI.
  return $response->content;
}
1;
