require 'mkmf'

have_header("ruby/st.h")
have_header("st.h")
have_func("rb_enc_interned_str", "ruby.h") # Ruby 3.0+
have_func("rb_hash_new_capa", "ruby.h") # Ruby 3.2+

unless RUBY_PLATFORM.include? 'mswin'
  $CFLAGS << %[ -I.. -Wall -O3 #{RbConfig::CONFIG["debugflags"]} -std=gnu99]
end

if RUBY_VERSION.start_with?('3.0.')
  # https://bugs.ruby-lang.org/issues/18772
  $CFLAGS << ' -DRB_ENC_INTERNED_STR_NULL_CHECK=1 '
end

# checking if Hash#[]= (rb_hash_aset) dedupes string keys (Ruby 2.6+)
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


# checking if String#-@ (str_uminus) dedupes... ' (Ruby 2.5+)
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

# checking if String#-@ (str_uminus) directly interns frozen strings... ' (Ruby 3.0+)
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
