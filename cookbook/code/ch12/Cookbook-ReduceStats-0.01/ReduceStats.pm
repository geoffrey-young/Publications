package Cookbook::ReduceStats;

use Apache::Constants qw(OK DECLINED DECLINE_CMD);
use Apache::ModuleConfig ();

use DynaLoader ();

use 5.006;

our $VERSION = '0.01';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap($VERSION);

use strict;

sub handler {

  my $r = shift;

  my $cfg = Apache::ModuleConfig->get($r, __PACKAGE__);

  my $uri = $r->uri;

  # Allow translation if the URI matches an Alias...
  return DECLINED if grep { $uri =~ m/^$_/ } @{$cfg->{_alias}};

  # ... or if the URI matches an AliasMatch regex.
  return DECLINED if grep { $uri =~ m/$_/ } @{$cfg->{_alias_match}};

  # Remaining Location or LocationMatch directives don't need filenames
  # so we end the translation phase for them.
  return OK if grep { $uri =~ m/^$_/ } @{$cfg->{_location}};
  return OK if grep { $uri =~ m/$_/ } @{$cfg->{_location_match}};
  
  # All others URIs should be filename based, so let them by.
  return DECLINED;
}

sub Alias ($$$$) {
  my ($cfg, $parms, $from, $to) = @_;

  if ($parms->info) {
    push @{$cfg->{_alias_match}}, qr/$from/
      unless grep /$from/, @{$cfg->{_alias_match}};
  }
  else {
    push @{$cfg->{_alias}}, $from
      unless grep /$from/, @{$cfg->{_alias}};
  }

  return DECLINE_CMD;
}

sub Location ($$$;*) {
  my ($cfg, $parms, $args, $fh) = @_;

  $args =~ s/>$//;  # get rid of the > end marker

  if ($parms->info || $args =~ m/~/ ) {
    (my $regex = $args) =~ s/~? *//;
    push @{$cfg->{_location_match}}, qr/$regex/
      unless grep /$regex/, @{$cfg->{_location_match}};
  }
  else {
    push @{$cfg->{_location}}, $args
      unless grep /$args/, @{$cfg->{_location}};
  }

  return DECLINE_CMD;
}

sub SERVER_CREATE {
  my $class = shift;
  my %self  = ();

  # Make sure we have entries to dereference.
  for my $entry (qw(_alias _alias_match _location _location_match)) {
    $self{$entry} = [];
  }

  return bless \%self, $class;
}

sub SERVER_MERGE {
  my ($parent, $current) = @_;
  my %new = (%$parent, %$current);

  return bless \%new, ref($parent);
}
1;
