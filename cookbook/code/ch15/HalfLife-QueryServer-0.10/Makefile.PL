use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'HalfLife::QueryServer',
    'PREREQ_PM'    => { NetPacket::UDP => 0, },
);
