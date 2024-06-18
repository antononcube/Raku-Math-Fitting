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

multi sub Fit(:$data where $data ~~ Seq, *%args) {
    return Fit(data => $data.List, |%args);
}

# Least squares, 1-dimensional regressor.
multi sub Fit($data where is-positional-of-lists($data, 2), :b(:$basis) is copy = Whatever, :p(:$prop) is copy = Whatever) {
    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    if $basis.isa(Whatever) || $basis.isa(WhateverCode) {
        my @coefficients = Math::Fitting::LinearRegression::Fit($data, prop => 'BestFitParameters')<intercept slope>;

        my $res = Math::Fitting::FittedModel.new(
                type => 'linear',
                :@coefficients,
                data => $data.Array,
                response-index => 1,
                basis-functions => [{ 1 }, { $_ }]);

        return $res;
    } else {
        return Fit(:$data, :$basis, :$prop);
    }
}

# Multidimensional Linear Least Squares delegation
multi sub Fit($data, :b(:$basis) is copy = Whatever, :p(:$prop) is copy = Whatever) {
    return Fit(:$data, :$basis, :$prop);
}

# Multidimensional Linear Least Squares.
multi sub Fit(:$data, :b(:$basis) is copy = Whatever, :p(:$prop) is copy = Whatever) {

    # If I put this package at the beginning of the file I get the error: "Undeclared routine:..."
    use Math::Matrix;

    #------------------------------------------------------
    # Process data
    #------------------------------------------------------
    if !is-positional-of-lists($data, Whatever) {
        die "The first argument is expected to be a list of lists that is matrix.";
    }

    #------------------------------------------------------
    # Process basis
    #------------------------------------------------------
    if $basis ~~ Seq:D { $basis = $basis.Array; }

    die 'The value of the argument $basis is expected to be a list of callables, Whatever, or WhateverCode.'
    unless $basis ~~ Positional:D && $basis.all ~~ Callable:D || $basis.isa(Whatever) || $basis.isa(WhateverCode);

    #------------------------------------------------------
    # Process prop
    #------------------------------------------------------
    if $prop.isa(Whatever) {
        $prop = 'Function';
    }

    #------------------------------------------------------
    # Computation
    #------------------------------------------------------

    # Design matrix
    my $X;
    if $basis.isa(Whatever) || $basis.isa(WhateverCode) {
        # Using the trivial basis
        $X = $data.map({ [1, |$_.head(*- 1)] });
    } else {
        # The basis is specified
        $X = $data.map({
            my @res = $basis.map(-> &f { &f(|$_.head(*- 1)) });
            @res
        });
    }
    $X = Math::Matrix.new($X);

    # Response
    my $y = $data.map({ [$_.tail,] });
    $y = Math::Matrix.new($y);

    # The Ordinary Least Squares (OLS) formula
    my $Fit = $X.transposed.dot-product($X).inverted.dot-product($X.transposed);

    # Assign coefficients
    my @coefficients = $Fit.dot-product($y).Array.map(*.head);

    # Make the functor
    my $res =
            Math::Fitting::FittedModel.new(
                    type => 'linear',
                    :@coefficients,
                    data => $data.Array,
                    response-index => $data.head.elems - 1,
                    :$basis);

    # Result
    return $res;
}