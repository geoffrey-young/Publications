package Cookbook::WinBitHack;

BEGIN {
  eval{ 
    require Win32::File;
    Win32::File->import(qw(READONLY ARCHIVE));
  };
}

use Apache::Constants qw(OK DECLINED OPT_INCLUDES DECLINE_CMD);
use Apache::File;
use Apache::ModuleConfig;

use DynaLoader;

use 5.006;

use strict;

our $VERSION = '0.01';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap($VERSION);

sub handler {
  # Implement XBitHack on Win32.
  # Usage: PerlModule Cookbook::WinBitHack
  #        PerlFixupHandler Cookbook::WinBitHack
  #        XBitHack On|Off|Full

  my $r = shift;

  my $cfg = Apache::ModuleConfig->get($r, __PACKAGE__);

  return DECLINED unless (
     $^O =~ m/Win32/                  &&    # we're on Win32
     -f $r->finfo                     &&    # the file exists
     $r->content_type eq 'text/html'  &&    # and is HTML
     $r->allow_options & OPT_INCLUDES &&    # and we have Options +Includes
     $cfg->{_state} ne 'OFF');              # and XBitHack On or Full

  # Gather the file attributes.
  my $attr;
  Win32::File::GetAttributes($r->filename, $attr);

  # Return DECLINED if the file has the ARCHIVE attribute set,
  # which is the usual case.
  return DECLINED if $attr & ARCHIVE();

  # Set the Last-Modified header unless the READONLY attribute is set.
  if ($cfg->{_state} eq 'FULL') {
    $r->set_last_modified((stat _)[9]) unless $attr & READONLY();
  }

  # Make sure mod_include picks it up.
  $r->handler('server-parsed');

  return OK;
}

sub DIR_CREATE {

  my $class = shift;
  my %self  = ();

  # XBitHack is disabled by default.
  $self{_state} = "OFF";

  return bless \%self, $class;
}

sub DIR_MERGE {

  my ($parent, $current) = @_;
  my %new = (%$parent, %$current);

  return bless \%new, ref($parent);
}

sub XBitHack ($$$) {

  my ($cfg, $parms, $arg) = @_;

  # Let mod_include do the Unix stuff - we only do Win32.
  return DECLINE_CMD unless $^O =~ m/Win32/;

  if ($arg =~ m/^(On|Off|Full)$/i) {
    $cfg->{_state} = uc($arg);
  }
  else {
    die "Invalid XBitHack $arg!";
  }
}
1;
