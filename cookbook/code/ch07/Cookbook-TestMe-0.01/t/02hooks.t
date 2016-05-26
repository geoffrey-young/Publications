# file t/02hooks.t

use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

plan tests => 1, \&have_lwp;

ok GET_OK '/hooks';
