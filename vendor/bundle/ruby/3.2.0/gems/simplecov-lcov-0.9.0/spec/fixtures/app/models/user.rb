# class User
#
# sample fixture
class User
  def foo
    "foo: #{@foo}"
  end

  def bar
    @a = 'bar'
  end

  def baz(b)
    @a = b
  end

  def uncovered
    @a = 'baz'
  end
end

User.new.foo
User.new.foo
User.new.bar
User.new.baz 'hello'
