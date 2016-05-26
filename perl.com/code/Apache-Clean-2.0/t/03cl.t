use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# test Content-Length logic

plan tests => 2, have_lwp;

# plain text is handled my default-handler which sets C-L
my $response = GET '/level/index.txt';
ok ($response->content_length == 58);

# html is handled by the filter which removes C-L
$response = GET '/level/index.html';
ok (! $response->content_length);
