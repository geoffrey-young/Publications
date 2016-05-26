package Cookbook::SetCookie;

use Digest::MD5;

use strict;

sub handler {

  my $r = shift;

  my $md5 = Digest::MD5->new;

  $md5->add($$, time(), $r->dir_config('SECRET'));

  my $session_cookie  = Apache::Cookie->new($r, 
                                            -name    =>  "sessionid",
                                            -value   =>  $md5->hexdigest,
                                            -path    =>  "/",
                                            -expires =>  "+10d"
                                           );
  # set the cookie
  $session_cookie->bake();

  my $identity_cookie = Apache::Cookie->new($r,
                                            -name    =>  "identity",
                                            -value   =>  'Arthur McCurry',
                                            -path    =>  "/hall_of_justice/",
                                            -expires =>  "+365d",
                                            -domain  =>  ".superfriends.com",
                                            -secure  =>  1
                                           );

  # change the value
  $identity_cookie->value('aquaman');

  $identity_cookie->bake();

  # Continue along...
}

1;
