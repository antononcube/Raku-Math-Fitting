unit module Math::Fitting;

use Math::Fitting::LinearModel;
use Math::Fitting::LinearRegression;

#----------------------------------------------------------
proto sub fit(|) is export {*}

multi sub fit($data, *%args) {
    die "Not implemented yet";
}

#----------------------------------------------------------
proto sub linear-regression(|) is export {*}

multi sub linear-regression($data, $prop, *%args) {
    return Math::Fitting::LinearRegression::Fit($data, :$prop, |%args);
}

multi sub linear-regression($data, *%args) {
    return Math::Fitting::LinearRegression::Fit($data, |%args);
}

#----------------------------------------------------------
proto sub linear-model-fit(|) is export {*}

multi sub linear-model-fit($data, $basis-functions, *%args) {
    return Math::Fitting::LinearModel::Fit($data, :$basis-functions, |%args);
}

multi sub linear-model-fit($data, $basis-functions, $prop, *%args) {
    return Math::Fitting::LinearModel::Fit($data, :$basis-functions, :$prop, |%args);
}

multi sub linear-model-fit($data, *%args) {
    return Math::Fitting::LinearModel::Fit($data, |%args);
}

multi sub linear-model-fit(:$data, *%args) {
    return Math::Fitting::LinearModel::Fit(:$data, |%args);
}