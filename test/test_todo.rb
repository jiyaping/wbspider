gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueueTodoTest < Minitest::Test
  include Wbspider

  def setup
    @q_length = 5
    @todo = QueueTodo.new(Wbspider::Done, @q_length)
  end

  def test_enqueue
    @todo.enqueue 10
    assert_equal 10, @todo.pop
  end

  def test_enqueue_equel_qlength
    @q_length.times do |i|
      @todo.enqueue i
    end

    assert_equal [0, 1, 2, 3, 4], @todo
  end

  def test_enqueue_more_than_qlength
    @q_length.times do |i|
      @todo.enqueue i
    end

    @todo.enqueue 100_000

    refute_includes @todo, 100_000, "when queue is full then throw it!"
  end

  def test_enqueue_value_has_exists_local
    @todo.enqueue 10
    @todo.enqueue 1
    @todo.enqueue 10

    assert_equal [10, 1], @todo
  end

  def test_dequeue
    @todo.enqueue 1
    @todo.enqueue 2
    @todo.enqueue 3

    assert_equal 1, @todo.dequeue
  end

  def test_dequeue_if_queue_empty
    refute @todo.dequeue
  end

  def test_dequeue_from_exists_db
    3.times do |i|
      @todo.dones.create(:value=> i)
    end

    @todo.enqueue 1
    @todo.enqueue 5

    refute_equal 1, @todo.dequeue
  end

  def teardown
    @todo.dones.delete_all
  end
end