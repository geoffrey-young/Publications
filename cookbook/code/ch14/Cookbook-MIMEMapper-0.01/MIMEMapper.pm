package Cookbook::MIMEMapper;

use Apache::Constants qw(OK DECLINED DECLINE_CMD);
use Apache::ModuleConfig ();

use 5.006;
use DynaLoader ();
use MIME::Types qw(by_suffix);

use strict;

our $VERSION = '0.01';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap($VERSION);

sub handler {

  my $r = shift;

  # Decline if the request is a proxy request.
  return DECLINED if $r->proxyreq;

  my $cfg = Apache::ModuleConfig->get($r, __PACKAGE__);

  # Also decline if a SetHandler directive is present,
  # which ought to override any AddHandler settings.
  return DECLINED if $cfg->{_set_handler};

  my ($extension) = $r->filename =~ m!(\.[^.]+)$!;

  # Set the PerlHandler stack if we have a mapping for this file extension.
  if (my $handlers = $cfg->{$extension}) {
    $r->handler('perl-script');
    $r->set_handlers(PerlHandler => $handlers);

    # Notify Apache::Filter if we have more than one PerlHandler...
    $r->dir_config->set(Filter => 'On') if @$handlers > 1;

    # ... and take a guess at the MIME type.
    my ($content_type) = by_suffix($extension);
    $r->content_type($content_type) if $content_type;

    return OK;
  }

  # Otherwise, let mod_mime handle things.
  return DECLINED;
}

sub AddHandler ($$@;@) {
  my ($cfg, $parms, $handler, $type) = @_;

  # Intercept the directive if the handler looks like a PerlHandler.
  # This is not an ideal check, but sufficient for the moment.
  if ($handler =~ m/::/) {
    push @{$cfg->{$type}}, $handler;
    return OK;
  }

  # Otherwise let mod_mime handle it.
  return DECLINE_CMD;
}

sub SetHandler ($$$) {
  my ($cfg, $parms, $handler) = @_;

  $cfg->{_set_handler} = 1;

  # We're just marking areas governed by SetHandler.
  return DECLINE_CMD;
}

sub DIR_CREATE {
  return bless {}, shift;
}

sub DIR_MERGE {
  my ($parent, $current) = @_;

  my %new = (%$parent, %$current);

  return bless \%new, ref($parent);
}
1;
