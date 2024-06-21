# Math::Fitting

Raku package for line, curve, and hyper-plane fitting over sets of points.

------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install Math::Fitting
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Math-Fitting.git
```

------

## Usage examples

### Linear regression (1D regressor)

Here is data that is an array of pairs logarithms of GDP and electricity production of different countries:

```raku
my @data =
        (11.773906839650255e0, 11.253864992156679e0), (12.171286902172696e0, 12.009204578014298e0),
        (12.107713405070312e0, 11.437962903093876e0), (12.696829332236298e0, 12.00401094268482e0),
        (11.28266350477445e0, 11.499283586840601e0), (12.585056018658895e0, 11.775388329493465e0),
        (10.723949075934968e0, 10.54745313463026e0), (11.389785159542825e0, 10.928944887584644e0),
        (13.167988368224217e0, 12.856756553879103e0), (11.019424327650983e0, 10.472888033769635e0),
        (10.198154686798192e0, 9.331143140569578e0), (11.395702941127277e0, 10.772811339725912e0),
        (12.031878183906066e0, 11.516569745919236e0), (11.430963567030055e0, 10.855585778720567e0),
        (10.21302480711734e0, 10.138888016785716e0), (11.857393542118762e0, 11.520472966745002e0),
        (11.223299730942632e0, 10.933368427760566e0), (12.15978767072575e0, 11.78868016913858e0),
        (11.190367918582032e0, 10.557867961568022e0), (11.733248321280731e0, 11.226857570288722e0),
        (10.839510106614012e0, 10.677157910153495e0), (11.191959374358786e0, 11.17621400228234e0),
        (12.215911663039382e0, 11.808235068507617e0), (12.420008212627797e0, 11.723537761532056e0),
        (11.551553518127756e0, 10.519077512018512e0), (11.845171164859963e0, 11.528956530193586e0),
        (12.212327463463307e0, 11.782617762483701e0), (11.479897117669006e0, 11.355095745306354e0),
        (13.320906155798967e0, 12.6405552706939e0);
        
@data.elems;        
```

**Remark:** The data was taken from ["Data::Geographics"](https://raku.land/zef:antononcube/Data::Geographics), [AAp1].

Here is a corresponding plot (using ["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp2]):

```raku
use Text::Plot;

text-list-plot(@data, title => 'lg(GDP) vs lg(Electricity Production)', x-label => 'GDP', y-label => 'EP');
```

Here is corresponding linear model fit, a functor (i.e. objects that does `Callable`):

```raku
use Math::Fitting;
my &f = linear-model-fit(@data);
```

Here are the best fit parameters (fit coefficients):

```raku
&f('BestFitParameters');
```

Here we call the functor over a range of values:

```raku
(10..13)».&f
```


Here are the corresponding residuals:

```raku
text-list-plot(&f('residuals'))
```

### Multidimensional regression (2D regressor)

Here is a matrix with 3D data:

```perl6
use Data::Reshapers;

(1..2) X (1..3)
==> { .map({ [|$_, sin($_.sum)] }) }()
==> my @data3D;

to-pretty-table(@data3D);
````

Here is a functor for the multidimensional fit: 

```perl6
my &mf = linear-model-fit(@data3D);
```

Here are the best parameters:

```perl6
&mf('BestFitParameters');
```

Here is a predicated value:

```perl6
&mf(2.5, 2.5);
```

Here is plot of the residuals:

```perl6
text-list-plot(&mf.fit-residuals);
```

### Using function basis

Data:

```perl6
use Data::Generators;

my @data = (-1, -0.95 ... 1);
@data = @data.map({ [$_, sqrt(abs($_/2)) + sin($_*2) + random-real((-0.25, 0.25))] });

text-list-plot(@data);
```

Basis functions:

```perl6
my @basis = {1}, {$_}, {-1 + 2 * $_ **2}, {-3 * $_ + 4 * $_ **3}, {1 - 8 * $_ ** 2 + 8 * $_ **4};
```

Compute the fit and show the best fit parameters:

```perl6
my &mf = linear-model-fit(@data, :@basis);

say 'BestFitParameters : ', &mf('BestFitParameters');
```

Plot the residuals:

```perl6
text-list-plot(&mf('FitResiduals'));
```

(Compare the plot values with the range of the added noise when `@data` is generated.)

------

## TODO

- [ ] TODO Implementation
  - [X] DONE Multi-dimensional Linear Model Fit (LMF)
  - [X] DONE Using user specified function basis
  - [ ] TODO More LMF diagnostics
  - [ ] TODO CLI for most common data specs
    - [ ] TODO Just a list of numbers
    - [ ] TODO String that is Raku full array
    - [ ] TODO String that is a JSON array

------

## References

[AAp1] Anton Antonov, 
[Data::Geographics Raku package](https://github.com/antononcube/Raku-Data-Geographics),
(2024),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, 
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022-2023),
[GitHub/antononcube](https://github.com/antononcube).

[PSp1] Paweł Szulc,
[Statistics::LinearRegression Raku package](https://github.com/hipek8/p6-Statistics-LinearRegression),
(2017),
[GitHub/hipek8](https://github.com/hipek8).
