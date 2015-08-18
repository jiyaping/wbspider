#encoding : utf-8

module Wbspider
  class Quene < Array
    attr_accessor :q_length, :db

    def initialize(db, qlength=5000)
      @q_length = qlength
      @db = db
    end

    def remote_get(value)
      db[:dones][:value=> value]
    end

    def remote_set(value)
      db[:dones].insert(:value=> value)
    end
  end
end
