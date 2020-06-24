[![Build Status](https://travis-ci.org/stphnlyd/perl5-Test2-Tools-PDL.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Test2-Tools-PDL)

# NAME

Test2::Tools::PDL - Test2 tools for verifying Perl Data Language piddles

# VERSION

version 0.0005

# SYNOPSIS

```perl
use Test2::Tools::PDL;

# Functions are exported by default.

# Ensure something is a piddle.
pdl_ok($x);

# Compare two piddles.
pdl_is($got, $expected, 'Same piddle.');
```

# FUNCTIONS

## pdl\_ok($thing, $name)

Checks that the given `$thing` is a [PDL](https://metacpan.org/pod/PDL) object.

## pdl\_is($got, $exp, $name);

Checks that piddle `$got` is same as `$exp`.

Now this method is internally similar as
`is($got->unpdl, $exp->unpdl)`. It's possible to work with both
numeric PDLs as well as non-numeric PDLs (like [PDL::Char](https://metacpan.org/pod/PDL%3A%3AChar), [PDL::SV](https://metacpan.org/pod/PDL%3A%3ASV)).

# DESCRIPTION 

This module contains tools for verifying [PDL](https://metacpan.org/pod/PDL) piddles.

# VARIABLES

This module can be configured by some module variables.

## TOLERANCE, TOLERANCE\_REL

These two variables are used when comparing float piddles. For
`pdl_is($got, $exp, ...)`, the effective tolerance is
`$TOLERANCE + abs($TOLERANCE_REL * $exp)`.

Default value of `$TOLERANCE` is same as
`$Test2::Compare::Float::DEFAULT_TOLERANCE`, which is `1e-8`.
Default value of `$TOLERANCE_REL` is 0.

For example, to use only relative tolerance,

```
{
    local $Test2::Tools::PDL::TOLERANCE = 0;
    local $Test2::Tools::PDL::TOLERANCE_REL = 1e-6;
    ...
}
```

# SEE ALSO

[PDL](https://metacpan.org/pod/PDL), [Test2::Suite](https://metacpan.org/pod/Test2%3A%3ASuite), [Test::PDL](https://metacpan.org/pod/Test%3A%3APDL)

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# CONTRIBUTOR

Mohammad S Anwar <manwar@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018-2020 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
