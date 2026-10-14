use ExtUtils::MakeMaker;

WriteMakefile(
    NAME			=> 'ZX81::Tape',
    AUTHOR			=> 'Paulo Custodio <pauloscustodio@gmail.com>',
    VERSION_FROM	=> 'lib/ZX81/Tape.pm',
    ABSTRACT_FROM	=> 'lib/ZX81/Tape.pm',
	LICENSE 		=> 'perl_5',
    PREREQ_PM		=> {
		'Modern::Perl'			=> 1.20250607,
		'Test::More'			=> 1.302225,
		'Test::HexDifferences'	=> 1.001,
		'ZX81::Tokenize'		=> 0.001,
        'Object::Tiny::RW'      => 1.07,
    },
);
