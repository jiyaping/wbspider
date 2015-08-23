gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class WbspiderTest < Minitest::Test
  include Wbspider

  def test_default_config
    assert_equal  File.join(Dir.home, 'wbspider'),
                Wbspider.home
  end

  def test_configure
    Wbspider.configure(:username=> 'jiyaping')

    assert_equal 'jiyaping', Wbspider.config[:username]
  end

  def test_configure_key_not_valid
    Wbspider.configure(:key_not_set => "ok")

    refute  Wbspider.config[:key_not_set]
  end

  def test_setup_db
    assert Wbspider.setup_db
  end
end