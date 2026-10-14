use Modern::Perl;
use Path::Tiny;
use Test::HexDifferences; 
use Test::More;

BEGIN { use_ok 'ZX81::Tape' }

for my $bas_file (path("t/input")->children(qr/\.bas$/)) {
    my $exp_p_file = path("t/expected")->child($bas_file->basename(".bas") . ".p");
    my @basic_lines = $bas_file->lines;

    my $tape = ZX81::Tape->new();
    for my $line (@basic_lines) {
        $tape->add_basic($line);
    }
    my $p_bytes = $tape->as_bytes();

    eq_or_dump_diff($p_bytes, path($exp_p_file)->slurp_raw, {address => 0x4009});
}

done_testing;
