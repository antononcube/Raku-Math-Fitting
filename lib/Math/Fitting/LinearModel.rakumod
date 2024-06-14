use v6.d;

unit module Math::Fitting::LinearModel;

use Math::Fitting::FittedModel;

sub is-positional-of-lists($obj, UInt $l) is export {
    $obj ~~ Positional && ([and] $obj.map({ $_ ~~ List && $_.elems == $l }))
}

#----------------------------------------------------------
# LinearRegression
#----------------------------------------------------------
# MVP version of Fit kept of testing;

our proto sub LinearRegression(|) {*}

multi sub LinearRegression(@data where @data.all ~~ Numeric:D, *%args) {
    my $k = 1;
    my @data2 = @data.map({ ($k++, $_) });
    return LinearRegression(@data2, |%args);
}

multi sub LinearRegression($data where $data ~~ Seq, *%args) {
    return LinearRegression($data.List, |%args);
}

multi sub LinearRegression($data where is-positional-of-lists($data, 2), :p(:$prop) is copy = Whatever) {

    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    die 'The value of $prop is expected to be a string or Whatever'
    unless $prop ~~ Str:D;

    my $n = $data.elems;
    my ($sum-x, $sum-y, $sum-xy, $sum-x2) = (0, 0, 0, 0);

    for |$data -> ($x, $y) {
        $sum-x  += $x;
        $sum-y  += $y;
        $sum-xy += $x * $y;
        $sum-x2 += $x * $x;
    }

    my $slope = ($n * $sum-xy - $sum-x * $sum-y) / ($n * $sum-x2 - $sum-x ** 2);
    my $intercept = ($sum-y - $slope * $sum-x) / $n;

    return do given $prop.lc {
        when $_ ∈ <BestFitParameters params best-fit-parameters coefficients>».lc {
            %(:$slope, :$intercept)
        }
        when $_ ∈ <function func callable> {
            -> $x {
                if $x ~~ Iterable:D {
                    $slope <<*<< $x.Array >>+>> $intercept
                } else {
                    $slope * $x + $intercept
                }
            }
        }
        when $_ ∈ <residuals FitResiduals>».lc {
            # It would be nice to use the function created above.
            # (($slope <<*<< $data.map(*.head) >>+>> $intercept) Z- $data.map(*.tail))».abs;
            # The following line is easier to read than the above line:
            $data.map({ $slope * $_.head + $intercept - $_.tail }).Array
        }
        default {
            die "Unknown property spec.";
        }
    }
}


#----------------------------------------------------------
# Fit
#----------------------------------------------------------

our proto sub Fit(|) {*}

multi sub Fit(@data where @data.all ~~ Numeric:D, *%args) {
    my $k = 1;
    my @data2 = @data.map({ ($k++, $_) });
    return Fit(@data2, |%args);
}

multi sub Fit($data where $data ~~ Seq, *%args) {
    return Fit($data.List, |%args);
}

multi sub Fit($data where is-positional-of-lists($data, 2), :p(:$prop) is copy = Whatever) {
    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    my @coefficients = LinearRegression($data, prop => 'BestFitParameters')<intercept slope>;

    my $res = Math::Fitting::FittedModel.new(type => 'linear', :@coefficients, data => $data.Array, response-index => 1);

    return $res;
}