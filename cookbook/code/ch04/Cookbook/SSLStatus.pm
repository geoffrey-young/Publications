package Cookbook::SSLStatus;

use Apache::URI;

use strict;

# Add a menu item to /perl-status that shows whether this 
# server is SSL ready.
# Actually, it just relies on the -DSSL command line switch,
# but since that's the convention...

if (Apache->module('Apache::Status')) {
  Apache::Status->menu_item('SSL',
                            'SSL status',
                            \&status);

  sub status {
    my $r = shift;

    my $ssl = $r->define('SSL');

    my @string = ("Apache was started ",
                  $ssl ? "with " : "without ",
                  "-DSSL");

    if ($ssl) {
      my $uri = Apache::URI->parse($r);
   
      $uri->scheme('https');

      my $new_uri = $uri->unparse;

      push @string, qq!<br><a href="$new_uri">
                       Go to this page via a secure connection</a>
                      !;
    }

    return \@string;
  }
}
1;
