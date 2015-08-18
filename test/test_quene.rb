gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueneTest < Minitest::Test
  include Wbspider

  def setup
    @db = Sequel.sqlite
    @db.create_table? :dones do
      primary_key :id
      String      :value
    end
    @quene = Quene.new(@db, 5)
  end

  def test_initialize_size
    assert_equal 0, @quene.size
  end

  def test_remote_set
    assert @quene.remote_set(10)
  end

  def test_remote_get
    @quene.remote_set(10)
    assert '10', @quene.remote_get(10)[:value]
  end
end