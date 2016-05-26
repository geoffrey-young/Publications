package Cookbook::Clean;

use ExtUtils::MakeMaker;
use Apache::ExtUtils qw(command_table);
use Apache::src ();
use Config;

use strict;

my @directives = (
  { name         => 'CleanLevel',
    errmsg       => 'Level of suds',
    args_how     => 'TAKE1',
    req_override => 'OR_ALL', },

  { name         => 'CleanOption',
    errmsg       => 'Specific detergent to use when cleaning',
    args_how     => 'ITERATE',
    req_override => 'OR_ALL', },
);

command_table(\@directives);

my %config;

$config{INC} = Apache::src->new->inc;

if ($^O =~ m/Win32/) {
  require Apache::MyConfig;

  $config{DEFINE}  = ' -D_WINSOCK2API_ -D_MSWSOCK_ ';
  $config{DEFINE} .= ' -D_INC_SIGNAL -D_INC_MALLOC '
    if $Config{usemultiplicity};

  $config{LIBS} =
    qq{ -L"$Apache::MyConfig::Setup{APACHE_LIB}" -lApacheCore } .
    qq{ -L"$Apache::MyConfig::Setup{MODPERL_LIB}" -lmod_perl};
}

WriteMakefile(
  NAME           => 'Cookbook::Clean',
  VERSION_FROM   => 'Clean.pm',
  PREREQ_PM      => { mod_perl    => 1.26,
                      'HTML::Clean' => 0.8, },
  ABSTRACT       => 'An XS-based Apache module',
  AUTHOR         => 'authors@modperlcookbook.org',
  clean          => { FILES => '*.xs*' },
  %config,
);
