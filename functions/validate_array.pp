# NIOBIUM (it#360): stdlib 6.5's validate_array() (removed in stdlib 9).
function ssh::validate_array(Any *$values) {
  $values.each |$v| { unless $v =~ Array { fail("${v} is not an Array.") } }
}
