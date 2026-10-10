# NIOBIUM (it#360): stdlib 6.5's validate_bool() (removed in stdlib 9): a real
# true/false only, as is_bool() was.
function ssh::validate_bool(Any *$values) {
  $values.each |$v| { unless $v =~ Boolean { fail("${v} is not a boolean.") } }
}
