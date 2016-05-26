package Cookbook::Clean;

use Apache::Constants qw( OK DECLINED );
use Apache::File;
use Apache::Log;
use Apache::ModuleConfig;

use Cache::Cache;
use Cache::SharedMemoryCache;
use DynaLoader ();
use HTML::Clean;

use 5.006;

our $VERSION = '0.03';
our @ISA = qw(DynaLoader);

__PACKAGE__->bootstrap($VERSION);

use strict;

# Get the package modification time...
(my $package = __PACKAGE__) =~ s!::!/!g;
my $package_mtime = (stat $INC{"$package.pm"})[9];

# ...and when httpd.conf was last modified
my $conf_mtime = (stat Apache->server_root_relative('conf/httpd.conf'))[9];

# Initialize the cache.
my %filedata = ();
die "Could not initialize cache!"
  unless Cache::SharedMemoryCache->new->set(file => \%filedata);

# When the server is restarted we need to...
Apache->server->register_cleanup(sub { 
  # clear the server cache, and
  Cache::SharedMemoryCache->Clear;

  # make sure we recognize config file changes and propigate
  # them to the client to clear the client cache if necessary.
  $conf_mtime = (stat Apache->server_root_relative('conf/httpd.conf'))[9]; 
});

sub handler {

  my $r = shift;

  my $filename = $r->filename;

  my $cfg = Apache::ModuleConfig->get($r, __PACKAGE__);

  return DECLINED unless ($r->content_type eq 'text/html');

  my $fh = Apache::File->new($filename);

  return DECLINED unless $fh;

  # Check to see if we need to generate new data or
  # if we can use the data we have.
  my $cache = Cache::SharedMemoryCache->new;

  my $filedata = $cache->get('file');

  my $file_mtime = (stat $r->finfo)[9];
  my $cache_mtime = $filedata->{$filename}->{_mtime};

  # Generate a new cache for the file if...
  unless ($cache_mtime &&                   # we don't have a cache
          $cache_mtime == $file_mtime) {    # or the file has changed

    my $dirty = do {local $/; <$fh>};

    my $h = HTML::Clean->new(\$dirty);

    $h->level($cfg->{_level});

    $h->strip($cfg->{_options});

    # Initialize the cache with the data for this file.
    $filedata->{$filename}{_clean} = ${$h->data};

    $filedata->{$filename}{_mtime} = $file_mtime;

    $cache->set(file => $filedata);
  }

  # At this point we have clean HTML, either cached or freshly generated.
  my $clean = $filedata->{$filename}->{_clean};

  # Send the data with proper expire headers so we get
  # both client and server side caching working.
  $r->update_mtime($package_mtime);
  $r->update_mtime($file_mtime);
  $r->update_mtime($conf_mtime);
  $r->set_last_modified;
  $r->set_content_length(length $clean);

  if ((my $status = $r->meets_conditions) == OK) {
    $r->send_http_header('text/html');
    print $clean;
    return OK;
  }
  else {
    return $status;
  }
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
