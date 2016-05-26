package Cookbook::SubRequestContent;

use Apache::Table;
use Apache::URI;
use HTTP::Request;
use LWP::UserAgent;

use strict;

sub new {
  # Create a new Cookbook::SubRequestContent object.
  # Usage: my $sub = Cookbook::SubRequestContent->new($relative_uri);

  my ($caller, $subrequest) = @_;

  # Allow ourselves to be subclassed so we can add functionality later.
  my $class = ref($caller) || $caller;

  my $self = { _subrequest => $subrequest };

  # Bless the new object.
  bless $self, $class;

  # Initialize the object with all the necessary stuff.
  $self->_init;

  # Finally, return the object.
  return $self;
}

sub _init {
  # Do some initialization stuff.

  my $self = shift;

  my $r = Apache->request;

  # Create the new URI based on the current request
  # and relative URI given to the new() method.
  my $uri = Apache::URI->parse($r);
  $uri->path($self->{_subrequest});
 
  # Create the new HTTP::Request object.
  $self->{_request} = HTTP::Request->new(GET => $uri->unparse);

  # Create a new Apache::Table object to hold the headers.
  my $table = Apache::Table->new($r);

  # Now, populate our "subrequest" header table with the headers
  # from the current request, just like a real subrequest.
  $r->headers_in->do(sub {
    $table->set(@_);
    1;
  });
  
  # Add the Apache::Table object for later use.
  $self->{_headers_in} = $table;
}

sub headers_in {
  # Return the Apache::Table object containing the headers.
  # Usage: $sub->headers_in->set('Accept-Language' => 'es');

  return shift->{_headers_in};
}

sub status {
  # Return the status code of the response.
  # A normal subrequest allows us to check this before calling run(),
  # so if no response has been generated we have to get it ourselves.

  my $self = shift;

  $self->run unless $self->{_response};

  return $self->{_response}->code;
}

sub run {
  # Run the subrequest.

  my $self = shift;

  # If we called status(), then we already have the content.
  return $self->{_content} if $self->{_content};

  my $request = $self->{_request};

  # Extract out any set headers and pass them to our request.
  $self->{_headers_in}->do(sub {
    $request->header(@_);
    1;
  });

  # Pass request to the user agent and get a response back.
  my $response = LWP::UserAgent->new->request($request);

  # Add the HTTP::Response object for later use.
  $self->{_response} = $response;

  # Add the content for later use.
  $self->{_content} = $response->content;

  return $self->{_content};
}
1;
