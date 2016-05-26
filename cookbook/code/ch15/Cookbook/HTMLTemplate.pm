package Cookbook::HTMLTemplate;

use Apache::Constants qw(OK DECLINED SERVER_ERROR);

use HTML::Template;

use strict;

sub handler {

  my $r = shift;

  my $log = $r->server->log;

  return DECLINED unless $r->content_type eq 'text/html';

  # Open the template for the given filename.
  my $template = HTML::Template->new(filename => $r->filename);

  unless ($template) {
    $r->warn("Cannot open request - skipping...");
    return DECLINED;
  }

  # Set an array for printing environment variables in a loop.
  my @env_loopvals = map { {key=>$_, val=>$ENV{$_}} } keys %ENV;

  $template->param(env_vals => \@env_loopvals);

  # Set an individual template variables.
  $template->param(user => $r->user);

  $r->send_http_header('text/html');
  $r->print($template->output);

  return OK;
}
1;
