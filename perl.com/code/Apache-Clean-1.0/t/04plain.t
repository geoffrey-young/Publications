use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# make sure that non-HTML documents pass through unaltered

plan tests => 1, have_lwp;

my $response = GET '/level/index.txt';
chomp(my $content = $response->content);

ok ($content eq q!<i    ><strong>&quot;This is a test&quot;</strong></i   >!);
