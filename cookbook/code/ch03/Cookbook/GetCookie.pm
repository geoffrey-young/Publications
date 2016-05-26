package Cookbook::GetCookie;

use Apache::Request;
use Apache::Cookie;

use strict;

sub handler {

  my $r = Apache::Request->new(shift);

  my %cookiejar = Apache::Cookie->new($r)->parse;

  $r->send_http_header('text/plain');

  foreach my $cookie (keys %cookiejar) {
    $r->print($cookiejar{$cookie}->name, " => ",
              $cookiejar{$cookie}->value );
    $r->print("\n");
  }
}

1;
