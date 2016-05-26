package Cookbook::DetailedLog;

use Apache::Constants qw(OK);

use Time::HiRes qw(gettimeofday tv_interval);

use strict;

sub handler ($$) {

  my $this = shift;
  my $class = ref $this || $this;

  my $r = shift || Apache->request();
  my $self = {};

  $self->{_start}   = [gettimeofday];
  $self->{_request} = $r;

  bless $self, $class;

  $r->pnotes('DETAILED_LOG', $self);

  return OK;
}

sub DESTROY {

  my $self = shift;

  my $r = $self->{_request};

  my $entry = join(' ',
                        $$,
                        $r->uri,
                        time(),
                        tv_interval($self->{_start})
                  );

  print Cookbook::LogHandle $entry;
}
1;
