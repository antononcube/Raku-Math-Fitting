use v6.d;

class Math::Fitting::FittedModel
        does Callable {
    has $.type;
    has @.data;
    has $.response-index;
    has @.coefficients;
    has $.basis;

    method best-fit-parameters() {
        return self.coefficients;
    }

    method basis-functions() {
        return self.basis;
    }

    method fit-residuals() {
        my &f = self.function();
        my @res =
                self.data.map({
                    my @x = $_.clone;
                    my $r = @x.splice($!response-index, 1);
                    $r >>-<< &f(@x)
                }).map(*.head);

        return @res;
    }

    method standardized-residuals() {
        die "Not implemented.";
    }

    method function() {
        if $!basis.isa(Whatever) || $!basis.isa(WhateverCode) {
            -> *@x { sum([1, |@x] >>*<< self.coefficients) }
        } else {
            -> *@x {
                my @row = $!basis.map({ $_(|@x) });
                sum(@row >>*<< self.coefficients)
            }
        }
    }

    method design-matrix() {
        die "Not implemented.";
    }

    method response() {
        return @!data.map({ $_[$!response-index] }).Array;
    }

    method get-property($prop is copy = Whatever) {
        return do given $prop.lc {
            when $_ ∈ <BasisFunctions basis-functions basis>».lc {
                self.basis;
            }
            when $_ ∈ <BestFitParameters params best-fit-parameters coefficients>».lc {
                self.best-fit-parameters();
            }
            when $_ ∈ <residuals FitResiduals fit-residuals>».lc {
                self.fit-residuals()
            }
            when $_ ∈ <StandardizedResiduals standardized-residuals>».lc {
                self.standardized-residuals()
            }
            when $_ ∈ <function func callable> {
                self.function()
            }
            when $_ ∈ <DesignMatrix design-matrix>».lc {
                self.design-matrix()
            }
            when $_ ∈ <response regressand> {
                self.response()
            }
            default {
                die "Unknown property spec.";
            }
        }
    }

    #======================================================
    # CALL-ME
    #======================================================
    multi method CALL-ME(Str:D $prop) {
        return self.get-property($prop);
    }

    multi method CALL-ME(*@x) {
        if $!basis.isa(Whatever) || $!basis.isa(WhateverCode) {
            return sum([1, |@x] >>*<< self.coefficients);
        } else {
            my @row = $!basis.map({ $_(|@x) });
            return sum(@row >>*<< self.coefficients);
        }
    }

    #======================================================
    # Representation
    #======================================================
    multi method gist(::?CLASS:D:-->Str) {
        return "Math::Fitting::FittedModel(type => { $!type }, " ~
                "data => ({ @!data.elems }, { @!data.head.elems }), " ~
                "response-index => { $!response-index }, " ~
                "basis => { $!basis ~~ Iterable:D ?? $!basis.elems !! 'Whatever'})";
    }

    method Str() {
        return self.gist();
    }
}