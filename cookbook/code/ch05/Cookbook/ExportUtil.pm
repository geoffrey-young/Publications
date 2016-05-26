package Cookbook::ExportUtil;

use DynaLoader;
use Exporter;

use strict;

our @ISA = qw(Exporter);

our @EXPORT_OK = qw(unescape_uri unescape_uri_info escape_html
                    validate_password size_string);

# These need an Apache runtimme environment, so don't allow them.
our @EXPORT_NOT_OK = qw(escape_uri ht_time parsedate);

my $libref = 
  DynaLoader::dl_load_file("/usr/local/apache/libexec/libhttpd.so");

my $symref = DynaLoader::dl_find_symbol($libref, 
                                        "boot_Apache__Util");

my $coderef = DynaLoader::dl_install_xsub("Apache::Util::bootstrap", 
                                          $symref);

Apache->$coderef;

# Now, do the same for the Apache class to get at 
# unescape_uri() and unescape_url().
$symref = DynaLoader::dl_find_symbol($libref, 
                                     "boot_Apache");

$coderef = DynaLoader::dl_install_xsub("Apache::bootstrap", 
                                       $symref);

Apache->$coderef;

# Finally, we can import symbols for use within our class.
use  Apache::Util qw(unescape_uri unescape_uri_info escape_html
                     validate_password size_string);
