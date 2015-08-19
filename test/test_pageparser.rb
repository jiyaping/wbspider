gem "minitest"
require 'minitest/autorun'
require 'wbspider'
require 'open-uri'

class PageParser_Test < Minitest::Test
  include Wbspider::PageParser

  def setup
      @page = Nokogiri::HTML(open('test/weibo.html'))
      @nodes = @page.search("div[id*='M_']")
  end

  def test_node_size
    assert_equal  50, @nodes.size
  end
end