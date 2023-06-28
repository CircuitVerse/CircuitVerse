require 'mkmf'

have_header("ruby/st.h")
have_header("st.h")
have_func("rb_enc_interned_str", "ruby.h")

unless RUBY_PLATFORM.include? 'mswin'
  $CFLAGS << %[ -I.. -Wall -O3 -g -std=gnu99]
end
#$CFLAGS << %[ -DDISABLE_RMEM]
#$CFLAGS << %[ -DDISABLE_RMEM_REUSE_INTERNAL_FRAGMENT]
#$CFLAGS << %[ -DDISABLE_BUFFER_READ_REFERENCE_OPTIMIZE]
#$CFLAGS << %[ -DDISABLE_BUFFER_READ_TO_S_OPTIMIZE]

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
  # msgpack-ruby doesn't modify data came from RSTRING_PTR(str)
  $CFLAGS << %[ -DRSTRING_NOT_MODIFIED]
  # Rubinius C extensions don't grab GVL while rmem is not thread safe
  $CFLAGS << %[ -DDISABLE_RMEM]
end

# checking if Hash#[]= (rb_hash_aset) dedupes string keys
h = {}
x = {}
r = rand.to_s
h[%W(#{r}).join('')] = :foo
x[%W(#{r}).join('')] = :foo
if x.keys[0].equal?(h.keys[0])
  $CFLAGS << ' -DHASH_ASET_DEDUPE=1 '
else
  $CFLAGS << ' -DHASH_ASET_DEDUPE=0 '
end


# checking if String#-@ (str_uminus) dedupes... '
begin
  a = -(%w(t e s t).join)
  b = -(%w(t e s t).join)
  if a.equal?(b)
    $CFLAGS << ' -DSTR_UMINUS_DEDUPE=1 '
  else
    $CFLAGS += ' -DSTR_UMINUS_DEDUPE=0 '
  end
rescue NoMethodError
  $CFLAGS << ' -DSTR_UMINUS_DEDUPE=0 '
end

# checking if String#-@ (str_uminus) directly interns frozen strings... '
begin
  s = rand.to_s.freeze
  if (-s).equal?(s) && (-s.dup).equal?(s)
    $CFLAGS << ' -DSTR_UMINUS_DEDUPE_FROZEN=1 '
  else
    $CFLAGS << ' -DSTR_UMINUS_DEDUPE_FROZEN=0 '
  end
rescue NoMethodError
  $CFLAGS << ' -DSTR_UMINUS_DEDUPE_FROZEN=0 '
end

if warnflags = CONFIG['warnflags']
  warnflags.slice!(/ -Wdeclaration-after-statement/)
end

create_makefile('msgpack/msgpack')

