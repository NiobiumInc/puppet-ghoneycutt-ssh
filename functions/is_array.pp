# NIOBIUM (it#360): stdlib 6.5's is_array() (removed in stdlib 9).
function ssh::is_array(Any $value) >> Boolean {
  $value =~ Array
}
