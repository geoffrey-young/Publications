package Cookbook::Clean;

use Apache::Constants qw( OK DECLINED );
use Apache::File;
use Apache::Log;
use Apache::ModuleConfig;

use DynaLoader ();
use HTML::Clean;

use 5.006;

our $VERSION = '0.02';
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
  $h->level($cfg->{_level});

  # No need to check before dereferencing since we can now
  # initialize our data in DIR_CREATE().
  $h->strip($cfg->{_options});

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

sub DIR_CREATE {
  # Initialize an object instead of using the mod_perl default.

  my $class = shift;
  my %self  = ();

  $self{_level}   = 1;   # default to 1
  $self{_options} = {};  # now we don't have to check when dereferencing

  return bless \%self, $class;
}

sub DIR_MERGE {
  # Allow the subdirectory to inherit the configuration
  # of the parent, while overriding with anything more specific.

  my ($parent, $current) = @_;

  my %new = (%$parent, %$current);

  return bless \%new, ref($parent);
}
1;
