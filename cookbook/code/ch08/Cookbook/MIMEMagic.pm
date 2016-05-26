package Cookbook::MIMEMagic;

use Apache::Constants qw(OK);
use Apache::Module;

use File::MMagic;

use strict;

sub handler {

  my $r = shift;

  # Run mod_mime first to make sure things like SetHandler
  # and AddLanguage handled properly.
  my $cv = Apache::Module->find('mime')->type_checker;
  $r->$cv();

  # Now, insert our own processing to (possibly) override 
  # the Content-Type header for the resource.
  $r->content_type(File::MMagic->new->checktype_filename($r->filename));
    unless $r->content_type;

  return OK 
}
1;
