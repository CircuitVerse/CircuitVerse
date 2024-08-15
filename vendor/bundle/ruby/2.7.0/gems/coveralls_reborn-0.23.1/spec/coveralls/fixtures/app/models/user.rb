# Foo class
class Foo
  def initialize
    @foo = 'baz'
  end

  def bar
    @foo
  end

  def foo
    if @foo
      'bar'
    end
  end
end
