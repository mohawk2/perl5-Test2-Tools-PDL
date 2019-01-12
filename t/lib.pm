#!perl

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(diag_message);

use Safe::Isa;

# get message from events
sub diag_message {
    my ($events) = @_;
    return join( "\n", map { $_->$_call_if_can('message') } @$events );
}

1;
