use v6.d;

unit module Math::Fitting::LinearModel;

use Math::Fitting::FittedModel;

proto sub is-positional-of-lists($obj, |) {*}

multi sub is-positional-of-lists($obj, UInt $l)  {
    $obj ~~ Positional:D && ([and] $obj.map({ $_ ~~ List && $_.elems == $l }))
}

multi sub is-positional-of-lists($obj, Whatever)  {
    if $obj ~~ Positional:D {
        my $l = $obj.head.elems;
        ([and] $obj.map({ $_ ~~ List && $_.elems == $l }))
    } else {
        False
    }
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

#| Fit
our proto sub Fit(|) {*}

multi sub Fit(@data where @data.all ~~ Numeric:D, *%args) {
    my $k = 1;
    my @data2 = @data.map({ ($k++, $_) });
    return Fit(@data2, |%args);
}

multi sub Fit($data where $data ~~ Seq, *%args) {
    return Fit($data.List, |%args);
}

# Least squares, 1-dimensional regressor.
multi sub Fit($data where is-positional-of-lists($data, 2), :p(:$prop) is copy = Whatever) {
    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    my @coefficients = LinearRegression($data, prop => 'BestFitParameters')<intercept slope>;

    my $res = Math::Fitting::FittedModel.new(type => 'linear', :@coefficients, data => $data.Array, response-index => 1);

    return $res;
}


# Multidimensional Linear Least Squares.
multi sub Fit($data, :p(:$prop) is copy = Whatever) {

    # If I put this package at the beginning of the file I get the error: "Undeclared routine:..."
    use Math::Matrix;

    if !is-positional-of-lists($data, Whatever) {
        die "The first argument is expected to be a list of lists that is matrix.";
    }

    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    my $X = $data.map({ [1, |$_.head(*-1)] });
    $X = Math::Matrix.new($X);

    my $y = $data.map({[ $_.tail, ]});
    $y = Math::Matrix.new($y);

    # The Ordinary Least Squares (OLS) formula
    my $Fit = $X.transposed.dot-product($X).inverted.dot-product($X.transposed);

    my @coefficients = $Fit.dot-product($y).Array.map(*.head);

    my $res = Math::Fitting::FittedModel.new(type => 'linear', :@coefficients, data => $data.Array, response-index => $data.head.elems - 1);

    return $res;
}