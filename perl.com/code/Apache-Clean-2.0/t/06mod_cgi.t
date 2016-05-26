use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestRequest;
use Apache::TestUtil qw(t_write_perl_script);

use File::Spec::Functions qw(catfile);

# test mod_cgi + SSI + Apache::Clean

plan tests => 4, (have_lwp && 
                  have_cgi &&
                  have_module('include'));

# first, generate the CGI scripts with the proper shebang line

my @lines = <DATA>;
t_write_perl_script(catfile(qw(cgi-bin plain.cgi)), @lines[0,2]);
t_write_perl_script(catfile(qw(cgi-bin include.cgi)), @lines[1,2]);

# type text/plain should be unaltered

my $response = GET '/cgi-bin/plain.cgi';
chomp(my $content = $response->content);

ok ($content eq q!<strong>/cgi-bin/plain.cgi</strong>!);
ok ($response->content_type =~ m!text/plain!);

# type text/html should have shorter tags

$response = GET '/cgi-bin/include.cgi';
chomp($content = $response->content);

ok ($content eq q!<b>/cgi-bin/include.cgi</b>!);
ok ($response->content_type =~ m!text/html!);

__END__
print "Content-Type: text/plain\n\n";
print "Content-Type: text/html\n\n";
print '<strong><!--#echo var="DOCUMENT_URI" --></strong>';
