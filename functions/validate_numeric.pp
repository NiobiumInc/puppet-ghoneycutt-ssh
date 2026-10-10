# NIOBIUM (it#360): stdlib 6.5's validate_numeric(input, max, min) (removed in
# stdlib 9). input is a number, a numeric String, or an array of those; each
# must lie within [min, max] when given.
function ssh::validate_numeric(
  Any $input,
  Optional[Variant[Numeric, String]] $max = undef,
  Optional[Variant[Numeric, String]] $min = undef,
) {
  $num = /\A\s*[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?\s*\z/
  $mx = $max ? { undef => undef, '' => undef, default => Numeric("${max}".strip) }
  $mn = $min ? { undef => undef, default => Numeric("${min}".strip) }
  if $input =~ Hash { fail('validate_numeric(): Expected first argument to be a Numeric or Array, got Hash') }
  [$input].flatten.each |$v| {
    unless $v =~ Numeric or ($v =~ String and $v =~ $num) {
      fail("validate_numeric(): Expected ${v} to be a Numeric")
    }
    $n = Numeric("${v}".strip)
    if $mx != undef and $n > $mx { fail("validate_numeric(): Expected ${v} to be smaller or equal to ${mx}") }
    if $mn != undef and $n < $mn { fail("validate_numeric(): Expected ${v} to be greater or equal to ${mn}") }
  }
}
