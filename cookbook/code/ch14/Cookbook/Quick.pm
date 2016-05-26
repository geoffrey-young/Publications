package CPAN::Quick;

use CPAN;
use 5.006;

use strict;

our @ISA = qw(CPAN);

CPAN::Config->load if CPAN::Config->can('load');

# Here we redefine CPAN::Index::reload so as the
# index files are not reloaded.
{
local $^W = 0;
eval "sub CPAN::Index::reload { return }"
}

# package CPAN::Quick::Shell
# used to provide a programmer's interface such as
#    CPAN::Quick::shell->install($distribution);

package CPAN::Quick::Shell;
our @ISA = qw(CPAN::Shell);

1;
