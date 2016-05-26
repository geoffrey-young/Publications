use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# this tests whether we can properly
# store broken tags in the filter context
# if data is sent over multiple filter invocations

plan tests => 1, have_lwp;

my $response = GET '/extra';
chomp(my $content = $response->content);
ok($content eq ('x' x 1020) . '</body></html');

