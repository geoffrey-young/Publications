package CacheHTML;

use strict;
use Apache::Constants qw(OK SERVER_ERROR DECLINED);
use Apache::File ();

sub fixup_handler ($$) {
  my ($self, $r) = @_;

  my $timeout = 1440 / $self->ttl($r);

  my $file = $r->filename();

  # test age of file..

  if (-f $file && -M _ < $timeout) {
    print STDERR "using cache file $file\n";
    return(DECLINED);
  }

  print STDERR "generating $file\n";
  my $fake_r = CacheHTML::Apache->new($r);

  $self->handler($fake_r); # Note: uses subclass handler method

  my $fh = Apache::File->new(">$file") || return(SERVER_ERROR);
  print $fh $fake_r->data();
  $fh->close;

  $r->filename($file); # reset finfo
  return OK;
}

sub ttl {
  return (60);
}


# sample handler, needs to be subclassed

sub handler ($$) {
  my ($self, $r) = @_;

  $r->send_http_header('text/html'); # ignored..

  $r->print(" --- non subclassed request ----");

}


# a fake package, used to capture handler output

package CacheHTML::Apache;

use base qw(Apache);

sub new {
  my ($class, $r) = @_;

  $r ||= Apache->request;

  return bless { r => $r, data=>undef }, $class;
}

sub print {
  shift->{data} .= join('', @_);
}

sub send_http_header {};

sub data {
  return shift->{data};
}

1;
