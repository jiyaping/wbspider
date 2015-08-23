gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueneTest < Minitest::Test
  include Wbspider

  def setup
    @queue = Queue.new(Wbspider::Done, 5)
  end

  def test_initialize_size
    assert_equal 0, @queue.size
  end

  def test_remote_set
    assert @queue.remote_set(10)
  end

  def test_remote_get
    @queue.remote_set(10)
    assert '10', @queue.remote_get(10)[:value]
  end

  def teardown
    @queue.dones.delete_all
  end
end