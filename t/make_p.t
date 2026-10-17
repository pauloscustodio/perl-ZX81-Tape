use Modern::Perl;
use Path::Tiny;
use Test::HexDifferences; 
use Test::More;
use Text::Diff;

BEGIN { use_ok 'ZX81::Tape', 'make_p', 'dump_p', 'list_p' }

for my $input_bas_file (path("t/input")->children(qr/\.bas$/)) {
	note "input file: $input_bas_file";
	my $input_basename = $input_bas_file->basename(".bas");
    my $exp_p_file = path("t/expected")->child("$input_basename.p");
	my $exp_dump_file = path("t/expected")->child("$input_basename.txt");
	my $exp_list_file = path("t/expected")->child("$input_basename.bas");
	
	# make .p file from .bas and compare to expected
	make_p($input_bas_file, "$input_basename.p");
	compare_p($exp_p_file, "$input_basename.p");
	
	if (Test::More->builder->is_passing) {
		unlink "$input_basename.p";
	}
	
	# make dump file from .p and compare to expected
	dump_p($exp_p_file, "$input_basename.txt");
	compare_text($exp_dump_file, "$input_basename.txt");
	
	if (Test::More->builder->is_passing) {
		unlink "$input_basename.txt";
	}
	
	# make list file from .p and compare to expected
	list_p($exp_p_file, "$input_basename.bas");
	compare_text($exp_list_file, "$input_basename.bas");
	
	if (Test::More->builder->is_passing) {
		unlink "$input_basename.bas";
	}
	
	# round-trip
	list_p($exp_p_file, "$input_basename.2.bas");
	make_p("$input_basename.2.bas", "$input_basename.2.p");
	compare_p($exp_p_file, "$input_basename.2.p");
	
	if (Test::More->builder->is_passing) {
		unlink "$input_basename.2.bas", "$input_basename.2.p";
	}
}

done_testing;

sub compare_p {
	my($exp_p, $got_p) = @_;
	
	my $exp_bytes = path($exp_p)->slurp_raw;
	my $got_bytes = path($got_p)->slurp_raw; 

	eq_or_dump_diff($exp_bytes, $got_bytes, { address => 0x4009 }, 
					"diff $exp_p $got_p");
	if ($exp_bytes ne $got_bytes) {
		if ($ENV{DEVELOPPER}) {
			dump_p($exp_p, "$exp_p.txt");
			dump_p($got_p, "$got_p.txt");
			system "start \"\" WinMergeU.exe $exp_p.txt $got_p.txt";
		}
	}

	if (Test::More->builder->is_passing) {
		unlink "$exp_p.txt", "$got_p.txt";
	}
}

sub compare_text {
	my($exp_txt, $got_txt) = @_;
	
	my $diff = diff("$exp_txt", "$got_txt");
	ok $diff eq '', "diff $exp_txt $got_txt";
	if ($diff ne '') {
		warn $diff;
		if ($ENV{DEVELOPER}) {
            system "start \"\" WinMergeU.exe $exp_txt $got_txt";
		}
	}
}
