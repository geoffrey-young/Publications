package Cookbook::Userdir;

# A simple PerlTransHandler that mimics mod_userdir.

use Apache::Constants qw(OK DECLINED);

use strict;

sub handler {

  my $r = shift;

  # Capture the old DocumentRoot setting.
  my $old_docroot = $r->document_root;

  # We have to get a bit funky here to help out mod_dir.
  if (my ($user, $path) = $r->uri =~ m!^/~      # Starts with a slash-tilde
                                       ([^/]+)  # One or more characters that
                                                # are not a slash
                                       /?       # Zero or one trailing slashes
                                       (.*)     # All the rest
                                      !x) {
    # Set DocumentRoot to the new value.
    $r->document_root("/home/$user/public_html");

    # Set the URI to the path without the username.
    $r->uri("/$path");

    # Remember to set the original DocumentRoot back -
    # here we use a closure.
    $r->push_handlers(PerlCleanupHandler =>
                        sub {
                          shift->document_root($old_docroot);
                          return OK;
                        }
                     );
  }

  return DECLINED;

}
1;
