package Test2::Tools::PDL;

# ABSTRACT: Test2 tools for verifying Perl Data Language piddles

use 5.010;
use strict;
use warnings;

# VERSION

use Safe::Isa;
use Scalar::Util qw(blessed);
use Test2::API qw(context);
use Test2::Compare qw(compare strict_convert);
use Test2::Compare::Float;
use Test2::Tools::Compare qw(number within string);
use Test2::Util::Table qw(table);
use Test2::Util::Ref qw(render_ref);

use parent qw/Exporter/;
our @EXPORT = qw(pdl_ok pdl_is);

use constant DEFAULT_TOLERANCE => $Test2::Compare::Float::DEFAULT_TOLERANCE;
our $TOLERANCE = DEFAULT_TOLERANCE;

=func pdl_ok($thing, $name)

Checks that the given C<$thing> is a L<PDL> object.

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

Checks that piddle C<$got> is same as C<$exp>.

Now this method is internally similar as
C<is($got-E<gt>unpdl, $exp-E<gt>unpdl)>. It's possible to work with both
numeric PDLs as well as non-numeric PDLs (like L<PDL::Char>, L<PDL::SV>).

=cut

sub pdl_is {
    my ( $got, $exp, $name, @diag ) = @_;
    my $ctx = context();

    my $gotname = render_ref($got);
    unless ( $got->$_DOES('PDL') ) {
        $ctx->ok( 0, $name, ["First argument '$gotname' is not a piddle."] );
        $ctx->release;
        return 0;
    }
    unless ( $exp->$_DOES('PDL') ) {
        my $expname = render_ref($exp);
        $ctx->ok( 0, $name, ["Second argument '$expname' is not a piddle."] );
        $ctx->release;
        return 0;
    }

    my $exp_class = ref($exp);
    unless ( $got->$_DOES($exp_class) ) {
        $ctx->ok( 0, $name,
            ["'$gotname' does not match the expected type '$exp_class'."] );
        $ctx->release;
        return 0;
    }

    my $is_numeric = !( $exp->type eq 'byte' or $exp->$_DOES('PDL::SV') );

    my $delta = compare( $got->unpdl, $exp->unpdl,
        sub { convert( $_[0], $is_numeric ) } );

    if ($delta) {
        $ctx->ok( 0, $name, [ $delta->table, @diag ] );
    }
    else {
        $ctx->ok( 1, $name );
    }

    $ctx->release;
    return !$delta;
}

sub convert {
    my ( $check, $is_numeric ) = @_;

    if ( not ref($check) ) {
        if ($is_numeric) {
            return ( ( $TOLERANCE // 0 ) == 0
                ? number($check)
                : within( $check, $TOLERANCE ) );
        }
        else {
              return string($check);
        }
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

Defaultly it's same as C<$Test2::Compare::Float::DEFAULT_TOLERANCE>, which
is C<1e-8>. You can override it to adjust the tolerance of numeric
comparison. The behavior is like L<Test2::Tools::Compare/within>.

    $Test2::Tools::PDL::TOLERANCE = 0.01;

You can set this variable to 0 to force exact numeric comparison. In this
case the behavior is like L<Test2::Tools::Compare/number>.

    {
        local $Test2::Tools::PDL::TOLERANCE = 0;
        ...
    }

=head1 SEE ALSO

L<PDL>, L<Test2::Suite>, L<Test::PDL>

