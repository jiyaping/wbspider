# encoding : utf-8

module Wbspider
  class << self
    attr_accessor :config

    def configure
      yield self.config ||= Config.new
    end
  end

  class Config
    attr_accessor :uname, :password, :path, :start_from

    def initialize(opts={})
      :uname = opts[:uname]
      :password = opts[:password]
      :path = opts[:path] || File.join(Dir.home, "wbspider")
      :start_from = opts[:start_from]
    end
  end
end