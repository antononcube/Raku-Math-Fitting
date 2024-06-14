unit module Math::Fitting;

use Math::Fitting::LinearModel;

#----------------------------------------------------------
proto sub fit(|) is export {*}

multi sub fit($data, *%args) {
    die "Not implemented yet";
}

#----------------------------------------------------------
proto sub linear-model-fit(|) is export {*}

multi sub linear-model-fit($data, $prop, *%args) {
    return Math::Fitting::LinearModel::Fit($data, :$prop, |%args);
}

multi sub linear-model-fit($data, *%args) {
    return Math::Fitting::LinearModel::Fit($data, |%args);
}