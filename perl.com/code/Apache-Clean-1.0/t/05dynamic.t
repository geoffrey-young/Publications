use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# test dynamically generated content

plan tests => 2, have_lwp;

# dynamic but plain content should be unaltered

my $response = GET '/plain-dynamic';
chomp(my $content = $response->content);

ok ($content eq q!<i    ><strong>&quot;This is a test&quot;</strong></i   >!);

# dynamic HTML should get filtered

$response = GET '/html-dynamic';
chomp($content = $response->content);

ok ($content eq q!<i><b>&quot;This is a test&quot;</b></i>!);
