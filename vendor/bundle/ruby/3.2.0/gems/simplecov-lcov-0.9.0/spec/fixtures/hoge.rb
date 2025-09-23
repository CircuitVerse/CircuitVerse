# class Hoge
#
# sample fixture
class Hoge
  def initialize(foo)
    @foo = foo
  end

  def bar
    @a = 0.9 > 0.5 ? 'foo' : 'not foo'
    @a = 'bar'
  end

  def uncovered
    @a = 'baz'
  end
end

Hoge.new(1)
Hoge.new(2).bar
