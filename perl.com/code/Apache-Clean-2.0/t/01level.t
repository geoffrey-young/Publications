use strict;
use warnings FATAL => 'all';

use Apache::Test qw(plan ok have_lwp);
use Apache::TestRequest qw(GET);
use Apache::TestUtil qw(t_cmp);

# test CleanLevel

plan tests => 1, have_lwp;

my $response = GET '/level/index.html';
chomp(my $content = $response->content);

ok t_cmp(q!<i><b>&quot;This is a test&quot;</b></i>!, $content);
