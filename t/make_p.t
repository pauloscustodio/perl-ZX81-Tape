use Modern::Perl;
use Path::Tiny;
use Test::HexDifferences; 
use Test::More;

BEGIN { use_ok 'ZX81::Tape', 'make_p' }

for my $bas_file (path("t/input")->children(qr/\.bas$/)) {
    my $exp_p_file = path("t/expected")->child($bas_file->basename(".bas") . ".p");
    my $basic_text = $bas_file->slurp_raw;
    my $p_bytes = make_p($basic_text);

    eq_or_dump_diff($p_bytes, path($exp_p_file)->slurp_raw, {address => 0x4009});
}

done_testing;
