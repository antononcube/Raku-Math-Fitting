#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Math::Fitting;

my @data =
        [1.0, 1.0, 0.9092974268256817], [1.0, 2.0, 0.1411200080598672], [1.0, 3.0, -0.7568024953079283],
        [2.0, 1.0, 0.1411200080598672], [2.0, 2.0, -0.7568024953079283], [2.0, 3.0, -0.9589242746631385];

my &mf = linear-model-fit(@data);

say &mf('BestFitParameters');

say &mf(1, 2);
say &mf([1, 2]);
say &mf.response;

say &mf.fit-residuals;
