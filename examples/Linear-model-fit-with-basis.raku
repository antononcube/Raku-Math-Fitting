#!/usr/bin/env raku
use v6.d;

use lib <. lib>;

use Math::Fitting;
use Data::Generators;
use Mathematica::Serializer;

my @data = (-1, -0.98 ... *)[^100];
@data = @data.map({ [$_, sqrt(abs($_/2)) + sin($_*2) + random-real((-0.2, 0.2))] });


say (:@data);

my $wlData = encode-to-wl(@data);
say (:$wlData);

say "=" x 100;
say "Using basis functions";
say "=" x 100;


#my @basis = {1}, {$_}, {$_ ** 2}, {$_ ** 3};

my @basis = {1}, {$_}, {-1 + 2 * $_ **2}, {-3 * $_ + 4 * $_ **3}, {1 - 8 * $_ ** 2 + 8 * $_ **4};


my &mf = linear-model-fit(@data, :@basis);

say 'BestFitParameters : ', &mf('BestFitParameters');

say &mf(1);
say &mf([1,]);

say 'Response : ', &mf("Response");

say "Fit residuals: ", &mf("FitResiduals");
say "Basis functions : ", &mf("BasisFunctions");

say (10...13)».&mf;