require "helper"

class UnitHTML5Scrub < Loofah::TestCase
  include Loofah

  def test_scrub_css
    assert_equal Loofah::HTML5::Scrub.scrub_css("background: #ABC012"), "background:#ABC012;"
    assert_equal Loofah::HTML5::Scrub.scrub_css("background: #abc012"), "background:#abc012;"
  end
end
