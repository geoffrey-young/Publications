#!perl

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Apache::Clean',
    'VERSION'      => '1.0',
    'PREREQ_PM'    => { HTML::Clean    => 0.8,
                        mod_perl       => 1.27,
                        Apache::SSI    => 2.17,
                        Apache::Filter => 1.016 },
);

sub MY::test {
  eval {
    require Apache::Test;
    require Apache::TestMM;
    require Apache::TestRunPerl;

    Apache::TestMM->import(qw(test clean));
    Apache::TestMM::filter_args();

    Apache::TestRunPerl->generate_script();

    return Apache::TestMM->test;
  }

  or return <<EOF;
test::
\t\@echo This test suite requires Apache-Test,
\t\@echo which is available from the mod_perl 2.0 
\t\@echo sources, CPAN, or the httpd-test distribution.
EOF
}
