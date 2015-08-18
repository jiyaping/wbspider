gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueneDoneTest < Minitest::Test
  def setup
    @db = Sequel.sqlite
    @db.create_table? :dones do
      primary_key :id
      String      :value
    end
    @q_length = 5
    @dones = Wbspider::QueneDone.new(@db, @q_length)
  end

  def test_add
    @dones.add 10

    assert_equal 1, @dones.size
  end

  def test_add_remote
    @dones.add 10

    assert_equal  1, @db[:dones].count
  end

  def test_add_five_item 
    @q_length.times do |i|
      @dones.add i
    end

    assert_equal [0, 1, 2, 3, 4], @dones
  end

  def test_add_over_five_item
    @q_length.times do |i|
      @dones.add i
    end

    @dones.add 10

    assert_equal [1, 2, 3, 4, 10], @dones
  end

  def test_add_over_five_item_remote
    @q_length.times do |i|
      @dones.add i
    end

    @dones.add 10

    assert_equal @q_length + 1, @db[:dones].count
  end
end