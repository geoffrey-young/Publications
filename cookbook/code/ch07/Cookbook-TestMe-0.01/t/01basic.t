# file t/01basic.t

use strict;
use warnings FATAL => 'all';

use Apache::Test;

plan tests => 4;

ok require 5.006001;
ok require mod_perl;
ok $mod_perl::VERSION >= 1.26;
ok require Cookbook::TestMe
