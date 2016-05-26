package Cookbook::CacheContent;

use Apache;
use Apache::Constants qw(OK SERVER_ERROR DECLINED);
use Apache::File ();

@Cookbook::CacheContent::ISA = qw(Apache);

use strict;

sub disk_cache ($$) {

  my ($self, $r) = @_;

  my $log = $r->server->log;

  my $file = $r->filename;

  # Convert configured minutes to days for -M test.
  my $timeout = $self->ttl($r) / (24*60);

  # Test age of file.
  if (-f $r->finfo && -M _ < $timeout) {
    $log->info("using cache file '$file'");
    return DECLINED;
  }

  # No old file to use, so make a new one.
  $log->info("generating '$file'");

  # First, create a request object from our Capture class below.
  my $fake_r = Cookbook::CacheContent::Capture->new($r);

  # Call the handler() subroutine of the subclass,
  # but pass it the fake $r so that we get the content back.
  $self->handler($fake_r);

  # Now, write the content from handler() to a file on disk.
  my $fh = Apache::File->new(">$file");

  unless ($fh) {
    $log->error("Cannot open '$file': $!");
    return SERVER_ERROR;
  }

  # Dump the content.
  print $fh $fake_r->data();

  # We need to call close() explicitly here or else
  # the Content-Length header does not get set properly.
  $fh->close;

  # Finally, reset the filename to point to the newly
  # generated file and let Apache's default handler send it.
  $r->filename($file);

  return OK;
}

sub ttl {
  # Get the cache time in minutes.
  # Default to 1 hour.

  return shift->dir_config('CacheTTL') || 60;
}

sub handler {

  my ($self, $r) = @_;

  $r->send_http_header('text/html'); # ignored...

  $r->print(" --- non-subclassed request --- ");
}  

package Cookbook::CacheContent::Capture;
# Capture handler output and stash it away.

@Cookbook::CacheContent::Capture::ISA = qw(Apache);

sub new {

  my ($class, $r) = @_;

  $r ||= Apache->request;

  tie *STDOUT, $class, $r;

  return tied *STDOUT;
}

sub print {
  # Intercept print so we can stash the data.

  shift->{_data} .= join('', @_);
}

sub data {
  # Return stashed data.

  return shift->{_data};
}

sub send_http_header {
  # no-op - don't send headers from a PerlFixupHandler.
};

sub TIEHANDLE {

  my ($class, $r) = @_;

  return bless { _r    => $r,
                 _data => undef
  }, $class;
}

sub PRINT {
  shift->print(@_);
}
1;

