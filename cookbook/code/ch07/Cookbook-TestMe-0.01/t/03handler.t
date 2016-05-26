# file t/03handler.t

use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, \&have_lwp;

my $content = GET_BODY '/handler/index.html';
chomp $content;
ok ($content eq "Thanks for using Cookbook::TestMe");
