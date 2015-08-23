# encoding : utf-8

module Wbspider
  class QueueTodo < Queue
    def enqueue(value)
      return if size >= @q_length
      return if index(value)

      push value
    end

    def dequeue
      begin
        value = shift
      end while remote_get(value)

      value
    end
  end
end