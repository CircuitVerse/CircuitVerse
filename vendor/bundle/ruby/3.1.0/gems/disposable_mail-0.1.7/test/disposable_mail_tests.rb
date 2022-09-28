require 'minitest/autorun'
require 'minitest/benchmark'
require 'minitest/pride'
require 'disposable_mail'

class TestDisposableMail < MiniTest::Test
  def test_list
    assert_kind_of Array, DisposableMail.list
    refute_empty DisposableMail.list

    DisposableMail.list.each do |domain|
      assert_kind_of String, domain
      refute_match /[@\s]/, domain
    end
  end

  def test_include
    DisposableMail.list.each do |domain|
      assert DisposableMail.include? "bot@#{domain}"
    end

    refute DisposableMail.include? "legit-person@yahoo.com"
    refute DisposableMail.include? "someone@gmail.com"
    refute DisposableMail.include? nil
  end
end
