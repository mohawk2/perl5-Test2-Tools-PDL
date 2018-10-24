package Test2::Tools::PDL;

# ABSTRACT: Test2 tools for verifying Perl Data Language piddles

use strict;
use warnings;

# VERSION

use Safe::Isa;
use Scalar::Util qw/blessed/;
use Test2::API qw/context/;
use Test2::Compare qw/compare strict_convert/;
use Test2::Compare::Float;
use Test2::Tools::Compare qw(within);
use Test2::Util::Table qw/table/;
use Test2::Util::Ref qw/render_ref/;

use parent qw/Exporter/;
our @EXPORT = qw(pdl_ok pdl_is);

our $TOLERANCE = $Test2::Compare::Float::DEFAULT_TOLERANCE;

=func pdl_ok($thing, $name)

Checks that the given C<$thing> is a L<Data::Frame::More> object.

=cut

sub pdl_ok {
    my ( $thing, $name ) = @_;
    my $ctx = context();

    unless ( $thing->$_DOES('PDL') ) {
        my $thingname = render_ref($thing);
        $ctx->ok( 0, $name, ["'$thingname' is not a piddle."] );
        $ctx->release;
        return 0;
    }

    $ctx->ok( 1, $name );
    $ctx->release;
    return 1;
}

=func pdl_is($got, $exp, $name);

Checks that data frame C<$got> is same as C<$exp>.

=cut

sub pdl_is {
    my ( $got, $exp, $name, @diag ) = @_;
    my $ctx = context();

    unless ( $got->$_DOES('PDL') ) {
        my $gotname = render_ref($got);
        $ctx->ok( 0, $name,
            ["First argument '$gotname' is not a piddle."] );
        $ctx->release;
        return 0;
    }
    unless ( $exp->$_DOES('PDL') ) {
        my $expname = render_ref($exp);
        $ctx->ok( 0, $name,
            ["Second argument '$expname' is not a piddle."] );
        $ctx->release;
        return 0;
    }

    my $delta = compare($got->unpdl, $exp->unpdl, \&convert); 

    if ($delta) {
        $ctx->ok(0, $name, [$delta->table, @diag]);
    }
    else {
        $ctx->ok(1, $name);
    }

    $ctx->release;
    return !$delta;
}

sub convert {
    my ($check) = @_;

    if (not ref($check)) {
        return within($check, $TOLERANCE);
    }
    return strict_convert(@_);
}

1;

__END__

=head1 SYNOPSIS

    use Test2::Tools::PDL;

    # Functions are exported by default.
    
    # Ensure something is a piddle.
    pdl_ok($x);

    # Compare two piddles.
    pdl_is($got, $expected, 'Same piddle.');
    
=head1 DESCRIPTION 

This module contains tools for verifying L<PDL> piddles.

=head1 VARIABLES

This module can be configured by some module variables.

=head2 TOLERANCE

Default is same as C<$Test2::Compare::Float::DEFAULT_TOLERANCE>, which is
C<1e-8>.

    $Test2::Tools::PDL::TOLERANCE = 0.01;

=head1 SEE ALSO

L<PDL>, L<Test2::Suite> 

