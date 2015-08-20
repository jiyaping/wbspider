#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class ConfigTest < Minitest::Test
  def setup
    @config = Wbspider::Config.new
  end

  def test_initalize
    assert @config
  end
end