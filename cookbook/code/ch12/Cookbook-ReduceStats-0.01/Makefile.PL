package Cookbook::ReduceStats;

use ExtUtils::MakeMaker;
use Apache::ExtUtils qw(command_table);
use Apache::src ();
use Config;

use strict;

my @directives = (
  { name         => 'Alias',
    errmsg       => 'stash Alias settings',
    args_how     => 'TAKE2',
    cmd_data     => '0',
    req_override => 'OR_ALL', },

  { name         => 'AliasMatch',
    errmsg       => 'stash AliasMatch settings',
    args_how     => 'TAKE2',
    func         => 'Alias',
    cmd_data     => '1',
    req_override => 'OR_ALL', },

  { name         => '<LocationMatch',
    errmsg       => 'stash LocationMatch settings',
    args_how     => 'RAW_ARGS',
    func         => 'Location',
    cmd_data     => '1',
    req_override => 'OR_ALL', },

  { name         => '<Location',
    errmsg       => 'stash Location settings',
    args_how     => 'RAW_ARGS',
    cmd_data     => '0',
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
  NAME           => 'Cookbook::ReduceStats',
  VERSION_FROM   => 'ReduceStats.pm',
  PREREQ_PM      => { mod_perl => 1.26_01 },
  ABSTRACT       => 'An XS-based Apache module',
  AUTHOR         => 'authors@modperlcookbook.org',
  clean          => { FILES => '*.xs*' },
  %config,
);
