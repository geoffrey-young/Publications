use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# test CleanOption

plan tests => 1, have_lwp;

my $response = GET '/option/index.html';
chomp(my $content = $response->content);

ok ($content eq q!<i><b>"This is a test"</b></i>!);
