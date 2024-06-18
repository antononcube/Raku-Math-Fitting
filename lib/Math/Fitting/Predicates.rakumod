use v6.d;

unit module Math::Fitting::Predicated;

# This is probably done better done with "Data::TypeSystem".

proto sub is-positional-of-lists($obj, |) is export {*}

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