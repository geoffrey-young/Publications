use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;

# test ModPerl::Registry + SSI + Apache::Clean

plan tests => 4, (have_lwp &&
                  have_module('include'));

# type text/plain should be unaltered

my $response = GET '/perl-bin/plain.pl';
chomp(my $content = $response->content);

ok ($content eq q!<strong>/perl-bin/plain.pl</strong>!);
ok ($response->content_type =~ m!text/plain!);

# type text/html should have shorter tags

$response = GET '/perl-bin/include.pl';
chomp($content = $response->content);

ok ($content eq q!<b>/perl-bin/include.pl</b>!);
ok ($response->content_type =~ m!text/html!);
