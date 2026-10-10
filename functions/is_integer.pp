# NIOBIUM (it#360): stdlib 6.5's is_integer() (removed in stdlib 9): an Integer,
# or a String of decimal digits without leading zeros (optionally negative).
function ssh::is_integer(Any $value) >> Boolean {
  $value =~ Integer or ($value =~ String and $value =~ /^-?(?:(?:[1-9]\d*)|0)$/)
}
