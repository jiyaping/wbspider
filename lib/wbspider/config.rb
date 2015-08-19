# encoding : utf-8

module Wbspider
  class << self
    attr_accessor :config, :db

    def configure
      yield self.config ||= Config.new
    end

    def setup_db
      @db = Sequel.connect(config.db_string)
      
      require 'wbspider/model/page'
      require 'wbspider/model/profile'
      require 'wbspider/model/relation'
      require 'wbspider/model/weibo'
      require 'wbspider/model/dbhandler'
    end
  end

  class Config
    attr_accessor :uname, :password, :path, :start_from, :db_string

    def initialize(opts={})
      @uname = opts[:uname]
      @password = opts[:password]
      @path = opts[:path] || File.join(Dir.home, "wbspider")
      @start_from = opts[:start_from]
      @db_string = opts[:db_string] || File.join(@path, "weibo.sqlite")
    end
  end
end