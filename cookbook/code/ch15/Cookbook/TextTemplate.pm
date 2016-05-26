package Cookbook::TextTemplate;

use Apache::Constants qw(OK DECLINED SERVER_ERROR);
use Apache::File;
use Apache::Log;

use Text::Template;

use strict;

sub handler {
  
  my $r = shift;
  my $log = $r->server->log;

  return DECLINED unless $r->content_type eq 'text/html';

  # Define some opening and closing markers.
  my $open = $r->dir_config('TemplateOpen') || "[--";
  my $close = $r->dir_config('TemplateClose') || "--]";

  # Get the requested resource.
  my $fh = Apache::File->new($r->filename);

  unless ($fh) {
    $log->warn("Cannot open request - skipping... $!");
    return DECLINED;
  }
 
  # Get some values that will be used in the template.
  # $elements should be a hash reference if it exists at all.
  my $elements = $r->pnotes('ELEMENTS');

  if ($elements && ref $elements ne 'HASH') {
    $log->error("Fill in elements must be contained in a hash");
    return SERVER_ERROR;
  }
 
  # Pass Text::Template the template 
  # (aka, the requested file) as a string
  my $template = new Text::Template (TYPE => 'STRING',
                                     SOURCE => do {local $/; <$fh>},
                                     DELIMITERS => [$open, $close]);

  unless ($template) {
    $log->error("Cannot create template: ", $Text::Template::ERROR);
    return SERVER_ERROR;
  } 

  # Explicitly compiling the template is optional, 
  # but it better informs us of any problems.
  my $compile = $template->compile;

  unless ($compile) {
    $log->error("Cannot compile template: ", $Text::Template::ERROR);
    return SERVER_ERROR;
  }

  # Finally, fill in the template with the data from pnotes.
  my $error;

  my $result = $template->fill_in(BROKEN => sub { my %args = @_;
                                                  my $ref  = $args{arg};
                                                  $$ref    = $args{error};
                                                  return; },
                                  BROKEN_ARG => \$error,
                                  HASH => $elements);

  unless ($result) {
    $log->error("Cannot fill in template: ", $error);
    return SERVER_ERROR;
  }

  # Send the results out to the client.
  $r->send_http_header('text/html');
  print $result;

  return OK;
}
1;
