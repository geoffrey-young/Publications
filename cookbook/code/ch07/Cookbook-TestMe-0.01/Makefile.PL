#!perl

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'              => 'Cookbook::TestMe',
    'VERSION_FROM'      => 'TestMe.pm',
);  

sub MY::test {
  if (eval "require Apache::TestMM") {
    Apache::TestMM::generate_script('t/TEST');
    Apache::TestMM->import(qw(test clean));
    return Apache::TestMM->test;
  }

  # The whitespace in front of @echo MUST be a single tab!
  return <<'EOF';
test::
	@echo This test suite requires Apache::Test
	@echo available from the mod_perl 2.0 sources
	@echo or the httpd-test distribution.
EOF
}
