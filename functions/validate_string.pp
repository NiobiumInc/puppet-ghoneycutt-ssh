# NIOBIUM (it#360): stdlib 6.5's validate_string() (removed in stdlib 9). Note
# that it also accepted undef.
function ssh::validate_string(Any *$values) {
  $values.each |$v| { unless $v =~ Optional[String] { fail("${v} is not a string.") } }
}
