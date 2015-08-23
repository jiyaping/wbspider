#encoding : utf-8

module Wbspider
  class Queue < Array
    attr_accessor :dones, :q_length

    def initialize(dones, qlength=5000)
      @dones = dones
      @q_length = qlength
    end

    def remote_get(value)
      @dones.find_by_value value
    end

    def remote_set(value)
      @dones.create :value=> value
    end
  end
end
