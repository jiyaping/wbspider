gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueueDoneTest < Minitest::Test
  def setup
    @q_length = 5
    @dones = Wbspider::QueueDone.new(Wbspider::Done, @q_length)
  end

  def test_add
    @dones.add 10

    assert_equal 1, @dones.size
  end

  def test_add_remote
    @dones.add 10

    assert_equal  1, @dones.dones.count
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

    assert_equal @q_length + 1, @dones.dones.count
  end

  def teardown
    @dones.dones.delete_all
  end
end