# Math::Fitting

Raku package for line, curve, and hyper-plane fitting into sets of points.

------

## Installation

From GitHub:

```
zef install https://github.com/antononcube/Raku-Math-Fitting.git
```

------

## Usage examples

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

Here is a corresponding plot:

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
(10...13)».&f
```

Here are the corresponding residuals:

```raku
text-list-plot(&f('residuals'))
```