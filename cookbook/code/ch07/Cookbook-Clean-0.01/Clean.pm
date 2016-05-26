package Cookbook::Clean;

use Apache::Constants qw( OK DECLINED );
use Apache::File;
use Apache::Log;
use Apache::ModuleConfig;

use DynaLoader ();
use HTML::Clean;

use 5.006;

our $VERSION = '0.01';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap($VERSION);

use strict;

sub handler {

  my $r = shift;

  my $log = $r->server->log;

  my $cfg = Apache::ModuleConfig->get($r, __PACKAGE__);

  unless ($r->content_type eq 'text/html') {
    $log->info("Request is not for an html document - skipping...");
    return DECLINED; 
  }

  my $fh = Apache::File->new($r->filename);

  unless ($fh) {
    $log->warn("Cannot open request - skipping... $!");
    return DECLINED;
  }

  # Slurp the file (hopefully it's not too big).
  my $dirty = do {local $/; <$fh>};

  # Create the new HTML::Clean object.
  my $h = HTML::Clean->new(\$dirty);

  # Set the level of suds.
  $h->level($cfg->{_level} || 1);

  # Make sure that we have a hash reference to dereference.
  my %options = $cfg->{_options} ? %{$cfg->{_options}} : ();

  # Clean the HTML.
  $h->strip(\%options);

  # Send the crisp, clean data.
  $r->send_http_header('text/html');
  print ${$h->data};

  return OK;
}

sub CleanLevel ($$$) {

  my ($cfg, $parms, $arg) = @_;

  die "Invalid CleanLevel $arg!" unless $arg =~ m/^[1-9]$/;

  $cfg->{_level}  = $arg;
}

sub CleanOption ($$@) {

  my ($cfg, $parms, $arg) = @_;


  my %possible = map {$_ => 1} qw(whitespace shortertags blink contenttype
                                  comments entities dequote defcolor
                                  javascript htmldefaults lowercasetags);

  if ($possible{lc $arg}) {
    $cfg->{_options}{lc $arg} = 1;
  }
  else {
    die "Invalid CleanOption $arg!";
  }
}
1;
