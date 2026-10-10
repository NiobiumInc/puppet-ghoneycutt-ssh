# NIOBIUM (it#360): stdlib 6.5's type3x() (removed in stdlib 9; on Ruby 3.2 it
# could not run at all -- it names Bignum/Fixnum). Returns 'boolean', 'array',
# 'hash', 'integer', 'float' or 'string'. As in stdlib, a String that
# round-trips through to_i ('22') is 'integer', through to_f ('1.5') 'float'.
function ssh::type3x(Any $value) >> String {
  case $value {
    Boolean: { 'boolean' }
    Array:   { 'array' }
    Hash:    { 'hash' }
    Integer: { 'integer' }
    Float:   { 'float' }
    String:  {
      if $value =~ /\A(?:0|-?[1-9]\d*)\z/ { 'integer' }
      elsif $value =~ /\A-?(?:0|[1-9]\d*)\.\d*[1-9]\z/ or $value =~ /\A-?(?:0|[1-9]\d*)\.0\z/ { 'float' }
      else { 'string' }
    }
    default: { fail('type3x(): Unknown type') }
  }
}
