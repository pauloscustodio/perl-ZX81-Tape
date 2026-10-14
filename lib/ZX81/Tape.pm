package ZX81::Tape;

use Modern::Perl;
use ZX81::Tokenize qw(tokenize_basic);

use Object::Tiny::RW qw{ basic };

our $VERSION = '0.001';

use Exporter qw(import);

our @EXPORT_OK = qw(
    make_p
);

sub new {
    my($class) = @_;
    my $self = bless {basic => []}, $class;
    return $self;
}

sub add_basic {
    my ($self, $basic) = @_;
    push @{$self->{basic}}, $basic;
}

sub as_bytes {
    my ($self) = @_;

    # Convert the stored BASIC lines to a byte string
    my $prog = '';
    for my $line (@{$self->{basic}}) {
        $prog .= tokenize_basic($line);
    }
    my $prog_start = 0x407D;
    my $e_ppc = $prog eq '' ? 0 : unpack("n", substr($prog, 0, 2));

    # Create an empty display file
    my $dfile = pack("C", 0x76);
    for (1..24){
        $dfile .= (pack("C", 0) x 32) . pack("C", 0x76);
    }
    my $dfile_start = $prog_start + length($prog);

    # Create an empty vars area
    my $vars = pack("C", 0x80);
    my $vars_start = $dfile_start + length($dfile);
    my $mem_end = $vars_start + length($vars);

    # Create the system variables
    my $bytes = '';
    $bytes .= pack("C", 0);                 # VERSN 
    $bytes .= pack("v", $e_ppc);            # E_PPC
    $bytes .= pack("v", $dfile_start);      # D_FILE
    $bytes .= pack("v", $dfile_start + 1);  # DF_CC
    $bytes .= pack("v", $vars_start);       # VARS
    $bytes .= pack("v", 0);                 # DEST
    $bytes .= pack("v", $mem_end);          # E_LINE
    $bytes .= pack("v", $mem_end + 1);      # CH_ADD
    $bytes .= pack("v", 0);                 # X_PTR
    $bytes .= pack("v", $mem_end + 2);      # STKBOT
    $bytes .= pack("v", $mem_end + 2);      # STKEND
    $bytes .= pack("C", 0);                 # BREG
    $bytes .= pack("v", 0x405d);            # MEM
    $bytes .= pack("C", 0);                 # not used
    $bytes .= pack("C", 2);                 # DF_SZ
    $bytes .= pack("v", 0);                 # S_TOP
    $bytes .= pack("v", 0xFFFF);            # LAST_K
    $bytes .= pack("C", 0x0F);              # DEBOUNCE
    $bytes .= pack("C", 55);                # MARGIN
    $bytes .= pack("v", $dfile_start);      # NXTLIN
    $bytes .= pack("v", 0);                 # OLDPPC
    $bytes .= pack("C", 0);                 # FLAGX
    $bytes .= pack("v", 0);                 # STRLEN
    $bytes .= pack("v", 0x0C6B);            # T_ADDR
    $bytes .= pack("v", 0);                 # SEED
    $bytes .= pack("v", 0xFFFF);            # FRAMES
    $bytes .= pack("C*", 0, 0);             # COORDS
    $bytes .= pack("C", 0xBC);              # PR_CC
    $bytes .= pack("C*", 33, 24);           # S_POSN
    $bytes .= pack("C", 0x40);              # CDFLAG - SLOW
    $bytes .= pack("C*", (0) x 32, 0x76);   # Print buffer
    $bytes .= pack("C*", (0) x 30);         # Calculator's memory area
    $bytes .= pack("C*", (0) x 2);          # not used

    # Pack the BASIC program, dfile and vars areas
    $bytes .= $prog;
    $bytes .= $dfile;
    $bytes .= $vars;
    
    return $bytes;
}

sub make_p {
    my ($basic) = @_;
    my $tape = ZX81::Tape->new();
    $tape->add_basic($basic);
    return $tape->as_bytes();
}

1;

__END__

#------------------------------------------------------------------------------

=pod

=head1 NAME

ZX81::Tape - Create ZX81 tape image files

=head1 SYNOPSIS

    use ZX81::Tape qw(make_p);
    
    my $bytes = make_p($basic);

    my $tape = ZX81::Tape->new();
    $tape->add_basic($basic);
    my $bytes = $tape->as_bytes();

=head1 DESCRIPTION

This module converts a BASIC source file passed as a string to a 
binary image of a ZX81 .p tape file.

=head1 FUNCTIONS

=head2 make_p

    my $bytes = make_p($basic);

Tokenizes the BASIC source text and builds a corresponding tape image 
to be loaded into an emulator.

=head1 METHODS

=head2 new

    my $tape = ZX81::Tape->new();

Creates a new ZX81::Tape object.

=head2 add_basic

    $tape->add_basic($basic);

Adds BASIC program lines to the tape. May be called multiple times 
to build up a complete program.

=head2 as_bytes

    my $bytes = $tape->as_bytes();

Returns the tape image as a byte string.

=head1 SEE ALSO

L<ZX81>
L<https://freestuff.grok.co.uk/zxtext2p/index.html>

=head1 AUTHOR

Paulo Custodio

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 Paulo Custodio.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
