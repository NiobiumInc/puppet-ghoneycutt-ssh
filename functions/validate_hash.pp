# NIOBIUM (it#360): stdlib 6.5's validate_hash() (removed in stdlib 9).
function ssh::validate_hash(Any *$values) {
  $values.each |$v| { unless $v =~ Hash { fail("${v} is not a Hash.") } }
}
