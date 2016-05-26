package Cookbook::MarkPhases;

use Apache::Constants qw(OK DECLINED);

use strict;

sub handler {
  # Push a handler onto each phase to mark its completion.
  # Note we skip the PerlHandler since this approach produces spurious
  # results with things like Apache::Registry and mod_dir.

  my $r = shift;

  foreach my $handler (qw(PerlPostReadRequestHandler PerlHeaderParserHandler
                          PerlTransHandler PerlAccessHandler PerlAuthenHandler
                          PerlAuthzHandler PerlTypeHandler PerlFixupHandler
                          PerlLogHandler PerlCleanupHandler)) {

    $r->push_handlers($handler => sub {
      my $r = shift;

      my $phase = $r->current_callback;

      print STDERR "***Finished processing for $phase\n";

      # Return DECLINED to avoid conflicts with certain phases.
      return DECLINED;
    });
  }
  return OK;
}
1;
