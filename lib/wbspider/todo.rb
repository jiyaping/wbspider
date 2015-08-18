# encoding : utf-8

module Wbspider
  class QueneTodo < Quene
    def enquene(value)
      return if size >= @q_length
      return if index(value)

      push value
    end

    def dequene
      begin
        value = shift
      end while remote_get(value)

      value
    end
  end
end