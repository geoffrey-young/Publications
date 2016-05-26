use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# this tests whether action on non-HTML responses
# allows other filters to still see the data

plan tests => 1, have_lwp;

my $response = GET '/decline';
chomp(my $content = $response->content);

ok ($content eq q!<I    ><STRONG>&QUOT;THIS IS A TEST&QUOT;</STRONG></I   >!);
