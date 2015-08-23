# encoding : utf-8

module Wbspider
  class QueueDone < Queue
    def add(value)
      shift if size >= @q_length

      push value
      remote_set value
    end

    def search(value)
      result = index(value)
      return result if result

      result = remote_get(value)
      if result
        shift if size >= @q_length
        push result[:value]

        return result[:value]
      end

      return nil
    end
  end
end