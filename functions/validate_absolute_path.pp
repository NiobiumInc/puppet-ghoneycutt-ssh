# NIOBIUM (it#360): stdlib 6.5's validate_absolute_path() (removed in stdlib 9).
# Each argument is a path or an array of paths; each path must be a String that
# Puppet::Util.absolute_path? accepts as POSIX (^/) or Windows.
function ssh::validate_absolute_path(Any *$values) {
  $values.each |$arg| {
    [$arg].flatten.each |$p| {
      $abs = $p =~ String and ($p =~ /^\// or $p =~ /^(?i:(?:[A-Z]:[\\\/])|(?:[\\\/][\\\/][^\\\/]+[\\\/][^\\\/]+)|(?:[\\\/][\\\/]\?[\\\/][^\\\/]+))/)
      unless $abs { fail("${p} is not an absolute path.") }
    }
  }
}
