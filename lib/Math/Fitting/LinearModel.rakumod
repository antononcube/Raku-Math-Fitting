use v6.d;

unit module Math::Fitting::LinearModel;

use Math::Fitting::FittedModel;
use Math::Fitting::LinearRegression;
use Math::Fitting::Predicates;


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

    my @coefficients = Math::Fitting::LinearRegression::Fit($data, prop => 'BestFitParameters')<intercept slope>;

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