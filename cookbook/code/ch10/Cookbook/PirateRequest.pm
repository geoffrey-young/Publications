package Cookbook::PirateRequest;

use Cookbook::TransformRequest;

@Cookbook::PirateRequest::ISA = qw(Cookbook::TransformRequest);

use strict;

sub as_pirate {

  my $arg = join('', @_);

  $arg =~ s/ boy/ matey/g;
  $arg =~ s/ yes/ aye/g;
  $arg =~ s/ my/ me/g;
  $arg =~ s/ treasure/ booty/g;

  return 'Argh! ' . $arg;
}

sub new {

  my($class, $r) = @_;

  if ($r->args =~ /pirate=1/) {
    return Cookbook::TransformRequest->new($r, undef, \&as_pirate);
  } else {
    return Apache::Request->new($r);
  }
}
1;

