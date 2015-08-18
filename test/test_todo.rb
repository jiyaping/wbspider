gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class QueneTodoTest < Minitest::Test
  include Wbspider

  def setup
    @db = Sequel.sqlite
    @db.create_table? :dones do
      primary_key :id
      String      :value
    end
    @q_length = 5
    @todo = QueneTodo.new(@db, @q_length)
  end

  def test_enquene
    @todo.enquene 10
    assert_equal 10, @todo.pop
  end

  def test_enquene_equel_qlength
    @q_length.times do |i|
      @todo.enquene i
    end

    assert_equal [0, 1, 2, 3, 4], @todo
  end

  def test_enquene_more_than_qlength
    @q_length.times do |i|
      @todo.enquene i
    end

    @todo.enquene 100_000

    refute_includes @todo, 100_000, "when quene is full then throw it!"
  end

  def test_enquene_value_has_exists_local
    @todo.enquene 10
    @todo.enquene 1
    @todo.enquene 10

    assert_equal [10, 1], @todo
  end

  def test_dequene
    @todo.enquene 1
    @todo.enquene 2
    @todo.enquene 3

    assert_equal 1, @todo.dequene
  end

  def test_dequene_if_quene_empty
    refute @todo.dequene
  end

  def test_dequene_from_exists_db
    3.times do |i|
      @db[:dones].insert(:value=> i)
    end

    @todo.enquene 1
    @todo.enquene 5

    refute_equal 1, @todo.dequene
  end
end