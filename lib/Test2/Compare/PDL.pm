package Test2::Compare::PDL;

# ABSTRACT: Internal representation of a piddle comparison.

use strict;
use warnings;
 
use parent 'Test2::Compare::Base';
 
# VERSION
 
use Test2::Util::HashBase qw/inref ending items order for_each/;
use Test2::Util::Ref qw/render_ref/;
 
use Carp qw/croak confess/;
use Safe::Isa;
use Scalar::Util qw/reftype looks_like_number/;
 
sub init {
    my $self = shift;

    if( defined( my $ref = $self->{+INREF}->unpdl ) ) {
        croak "Cannot specify both 'inref' and 'items'" if $self->{+ITEMS};
        croak "Cannot specify both 'inref' and 'order'" if $self->{+ORDER};
        croak "'inref' must be an array reference, got '$ref'" unless reftype($ref) eq 'ARRAY';
        my $order = $self->{+ORDER} = [];
        my $items = $self->{+ITEMS} = {};
        for (my $i = 0; $i < @$ref; $i++) {
            push @$order => $i;
            $items->{$i} = $ref->[$i];
        }
    }
    else {
        $self->{+ITEMS} ||= {};
        croak "All indexes listed in the 'items' hashref must be numeric"
            if grep { !looks_like_number($_) } keys %{$self->{+ITEMS}};
 
        $self->{+ORDER} ||= [sort { $a <=> $b } keys %{$self->{+ITEMS}}];
        croak "All indexes listed in the 'order' arrayref must be numeric"
            if grep { !(looks_like_number($_) || (ref($_) && reftype($_) eq 'CODE')) } @{$self->{+ORDER}};
    }
 
    $self->{+FOR_EACH} ||= [];

    $self->SUPER::init();
}
 
sub name { '<PDL>' }
 
sub verify {
    my $self = shift;
    my %params = @_;

    return 0 unless $params{exists};
    my $got = $params{got};
    return 0 unless $got->$_DOES('PDL');
    return 1;
}
 
sub top_index {
    my $self = shift;
    my @order = @{$self->{+ORDER}};
 
    while(@order) {
        my $idx = pop @order;
        next if ref $idx;
        return $idx;
    }
 
    return undef; # No indexes
}
 
sub add_item {
    my $self = shift;
    my $check = pop;
    my ($idx) = @_;
 
    my $top = $self->top_index;
 
    croak "elements must be added in order!"
        if $top && $idx && $idx <= $top;
 
    $idx = defined($top) ? $top + 1 : 0
        unless defined($idx);
 
    push @{$self->{+ORDER}} => $idx;
    $self->{+ITEMS}->{$idx} = $check;
}
 
sub add_filter {
    my $self = shift;
    my ($code) = @_;
    croak "A single coderef is required"
        unless @_ == 1 && $code && ref $code && reftype($code) eq 'CODE';
 
    push @{$self->{+ORDER}} => $code;
}
 
sub add_for_each {
    my $self = shift;
    push @{$self->{+FOR_EACH}} => @_;
}
 
sub deltas {
    my $self = shift;
    my %params = @_;
    my ($got, $convert, $seen) = @params{qw/got convert seen/};

    my @deltas;
    my $state = 0;
    my @order = @{$self->{+ORDER}};
    my $items = $self->{+ITEMS};
    my $for_each = $self->{+FOR_EACH};
 
    # Make a copy that we can munge as needed.
    my @list = @{$got->unpdl};
 
    while (@order) {
        my $idx = shift @order;
        my $overflow = 0;
        my $val;
 
        # We have a filter, not an index
        if (ref($idx)) {
            @list = $idx->(@list);
            next;
        }
 
        confess "Internal Error: Stacks are out of sync (state > idx)"
            if $state > $idx + 1;
 
        while ($state <= $idx) {
            $overflow = !@list;
            $val = shift @list;
 
            # check-all goes here so we hit each item, even unspecified ones.
            for my $check (@$for_each) {
                $check = $convert->($check);
                push @deltas => $check->run(
                    id      => [ARRAY => $state],
                    convert => $convert,
                    seen    => $seen,
                    exists  => !$overflow,
                    $overflow ? () : (got => $val),
                );
            }
 
            $state++;
        }
 
        confess "Internal Error: Stacks are out of sync (state != idx + 1)"
            unless $state == $idx + 1;
 
        my $check = $convert->($items->{$idx});
 
        push @deltas => $check->run(
            id      => [ARRAY => $idx],
            convert => $convert,
            seen    => $seen,
            exists  => !$overflow,
            $overflow ? () : (got => $val),
        );
    }
 
    while (@list && (@$for_each || $self->{+ENDING})) {
        my $item = shift @list;
 
        for my $check (@$for_each) {
            $check = $convert->($check);
            push @deltas => $check->run(
                id      => [ARRAY => $state],
                convert => $convert,
                seen    => $seen,
                got     => $item,
                exists  => 1,
            );
        }
 
        # if items are left over, and ending is true, we have a problem!
        if ($self->{+ENDING}) {
            push @deltas => $self->delta_class->new(
                dne      => 'check',
                verified => undef,
                id       => [ARRAY => $state],
                got      => $item,
                check    => undef,
 
                $self->{+ENDING} eq 'implicit' ? (note => 'implicit end') : (),
            );
        }
 
        $state++;
    }

    return @deltas;
}

# TODO: See https://github.com/Test-More/Test2-Suite/pull/168
sub run {
    my $self = shift;
    my %params = @_;
 
    my $id      = $params{id};
    my $convert = $params{convert} or confess "no convert sub provided";
    my $seen    = $params{seen} ||= {};
 
    $params{exists} = exists $params{got} ? 1 : 0
        unless exists $params{exists};
 
    my $exists = $params{exists};
    my $got = $exists ? $params{got} : undef;

    my $gotname = render_ref($got);
 
    # Prevent infinite cycles
    if (defined($got) && ref $got) {
        die "Cycle detected in comparison, aborting"
            if $seen->{$gotname} && $seen->{$gotname} >= Test2::Compare::Base::MAX_CYCLES();
        $seen->{$gotname}++;
    }
 
    my $ok = $self->verify(%params);
    my @deltas = $ok ? $self->deltas(%params) : ();
 
    $seen->{$gotname}-- if defined $got && ref $got;
 
    return if $ok && !@deltas;
 
    return $self->delta_class->new(
        verified => $ok,
        id       => $id,
        got      => $got,
        check    => $self,
        children => \@deltas,
        $exists ? () : (dne => 'got'),
    );
}
 
1;
 
__END__
 
=pod
 
=head1 DESCRIPTION
 
This module is an internal representation of a piddle for comparison purposes.
 
