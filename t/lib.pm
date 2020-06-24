#!perl

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(diag_message);

use Safe::Isa 1.000007;

# get message from events
sub diag_message {
    my ($events) = @_;
    return join(
        "\n",
        map {
            my $info = $_->facet_data->{info};
            map { $_->{details} } @$info;
        } @$events
    );
}

1;
