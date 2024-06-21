#!/usr/bin/env raku
use v6.d;

use Math::Fitting;
use Math::Polynomial::Chebyshev;
use Data::Generators;
use Text::Plot;

my @data = (-1, -0.95 ... 1);
@data = @data.map({ [$_, sqrt(abs($_/2)) + sin($_*2) + random-real((-0.4, 0.4))] });

say (:@data);

say "=" x 100;
say "Using basis functions";
say "=" x 100;


#my @basis = {1}, {$_}, {$_ ** 2}, {$_ ** 3};

#my @basis = {1}, {$_}, {-1 + 2 * $_ **2}, {-3 * $_ + 4 * $_ **3}, {1 - 8 * $_ ** 2 + 8 * $_ **4};

my @basis = (^5).map({ chebyshev-t($_) });

my &mf = linear-model-fit(@data, :@basis);

say 'BestFitParameters : ', &mf('BestFitParameters');

say &mf(1);
say &mf([1,]);

say 'Response : ', &mf("Response");

say "Fit residuals: ", &mf("FitResiduals");
say "Basis functions : ", &mf("BasisFunctions");


say '=' x 100;
say "Here is a plot of the data and the fit:";

my @fit = (-1, -0.98 ... 1).map({ [$_, &mf($_)] });
say <fit data> Z=> <* □>;
say text-list-plot([@fit, @data], width => 80)
