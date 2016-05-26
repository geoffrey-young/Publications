package Cookbook::Regex;

use Apache::Constants qw( :common );
use Apache::File;
use Apache::Log;

use strict;

sub handler {
  
  my $r = shift;

  my $log = $r->server->log;

  my @change = $r->dir_config->get('RegexChange');
  my @to     = $r->dir_config->get('RegexTo');
 
  unless ($r->content_type eq 'text/html') {
    $log->info("Request is not for an html document - skipping...");
    return DECLINED; 
  }

  unless (@change && @to) {
    $log->info("Parameters not set - skipping...");
    return DECLINED; 
  }

  if (@change != @to) {
    $log->error("Number of regex terms do not match!");
    return SERVER_ERROR;
  }

  my $fh = Apache::File->new($r->filename);

  unless ($fh) {
    $log->warn("Cannot open request - skipping... $!");
    return DECLINED;
  }

  $r->send_http_header('text/html');

  while (my $output = <$fh>) {
    for (my $i=0; $i < @change; $i++) {    
      $output =~ s/$change[$i]/$to[$i]/eeg;
    }
    print $output;
  }

  return OK;
}
1;
