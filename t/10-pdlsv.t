#!perl

use strict;
use warnings;

use Test2::API qw(intercept);
use Test2::V0;

use Test2::Tools::PDL;

plan skip_all => 'PDL::SV has to be patched to get this to work';

eval { require PDL::SV; };
if ($@) { plan skip_all => 'Requires PDL::SV'; }

subtest pdlsv => sub {

    my $test_name = 'PDL::SV->new([qw(foo bar)])';

    {
        my $events = intercept {
            pdl_is( PDL::SV->new( [qw(foo bar)] ),
                PDL::SV->new( [qw(foo bar)] ), $test_name );
        };

        my $event_ok = $events->[0];
        ok( $event_ok->pass, 'pdl_is($pdlsv)' );
    }
    {
        my $events = intercept {
            pdl_is( PDL::SV->new( [qw(foo baz)] ),
                PDL::SV->new( [qw(foo bar)] ), $test_name );
        };

        my $event_ok = $events->[0];
        ok( !$event_ok->pass, 'pdl_is($different_pdlsv) is expected to fail' );
    }
    {
        my $events = intercept {
            pdl_is( pdl( [ 0, 0 ] ),
                PDL::SV->new( [qw(foo bar)] ), $test_name );
        };

        my $event_ok = $events->[0];
        ok( !$event_ok->pass, 'pdl_is($pdl, $pdlsv) is expected to fail' );
    }
};

done_testing;