# NIOBIUM (it#360): stdlib 6.5's validate_re(), which stdlib 9 removed. Same
# contract: the value must be a String and match at least one of the regexes
# (unanchored, as Ruby's =~), else fail with the message.
function ssh::validate_re(
  Any $value,
  Variant[String, Array[String]] $regexes,
  Optional[String] $message = undef,
) {
  unless $value =~ String {
    fail("validate_re(): input needs to be a String, not ${type($value, 'generalized')}")
  }
  $ok = [$regexes].flatten.any |String $re| { $value =~ Regexp($re) }
  unless $ok {
    fail($message ? { undef => "validate_re(): '${value}' does not match ${regexes}", default => $message })
  }
}
