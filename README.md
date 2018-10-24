[![Build Status](https://travis-ci.org/stphnlyd/perl5-Test2-Tools-PDL.svg?branch=master)](https://travis-ci.org/stphnlyd/perl5-Test2-Tools-PDL)

# NAME

Test2::Tools::PDL - Test2 tools for verifying Perl Data Language piddles

# VERSION

version 0.0001

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

Checks that the given `$thing` is a [Data::Frame::More](https://metacpan.org/pod/Data::Frame::More) object.

## pdl\_is($got, $exp, $name);

Checks that data frame `$got` is same as `$exp`.

# DESCRIPTION 

This module contains tools for verifying [PDL](https://metacpan.org/pod/PDL) piddles.

# VARIABLES

This module can be configured by some module variables.

## TOLERANCE

Default is same as `$Test2::Compare::Float::DEFAULT_TOLERANCE`, which is
`1e-8`.

```
$Test2::Tools::PDL::TOLERANCE = 0.01;
```

# SEE ALSO

[PDL](https://metacpan.org/pod/PDL), [Test2::Suite](https://metacpan.org/pod/Test2::Suite) 

# AUTHOR

Stephan Loyd <sloyd@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Stephan Loyd.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
