use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# this is a test to see if our
# buffer logic works when our filter
# sends data to HTML::Clean in chunks.

plan tests => 4, have_lwp;

# <strong> is 8 characters long
# our buffer is 1024 characters
# so 1016 characters plus <strong> should
# pass exactly one buffer to our filter

my $response = GET '/long?1016';
chomp(my $content = $response->content);
ok($content eq ('x' x 1016) . '<b></b>');

# now the <strong> tag is broken when fed to
# HTML::Clean - make sure our buffer breaks
# the line properly so we don't end up
# with <strong></b>

$response = GET '/long?1017';
chomp($content = $response->content);
ok($content eq ('x' x 1017) . '<b></b>');

# the last test was <strong
# let's test the other end of our regex, just <

$response = GET '/long?1023';
chomp($content = $response->content);
ok($content eq ('x' x 1023) . '<b></b>');

# now we're fully into the second buffer

$response = GET '/long?1024';
chomp($content = $response->content);
ok($content eq ('x' x 1024) . '<b></b>');

