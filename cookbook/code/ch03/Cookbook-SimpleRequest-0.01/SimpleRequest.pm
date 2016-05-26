package Cookbook::SimpleRequest;

use 5.006;
use strict;
use warnings;

require Exporter;
require DynaLoader;

our @ISA = qw(Exporter DynaLoader);

our @EXPORT_OK = qw(assbackwards);

our $VERSION = '0.01';

__PACKAGE__->bootstrap($VERSION);

1;
