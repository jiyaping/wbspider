# encoding:utf-8

require 'mechanize'
require 'yaml'
require 'sequel'

require 'wbspider/quene'
require 'wbspider/todo'
require 'wbspider/dones'
require 'wbspider/agent'
require 'wbspider/version'

require 'wbspider/web/pageparser'
require 'wbspider/web/webpage'
require 'wbspider/web/follow'
require 'wbspider/web/profile'
require 'wbspider/web/webpage'
require 'wbspider/web/weibo'

module Wbspider
  class WbspiderError < StandardError; end
  class ConfigureError < WbspiderError; end
  class LoginError < WbspiderError; end

  # default config
  @config = {
    :username   =>  nil,
    :password   =>  nil,
    :path       =>  File.join(Dir.home, "wbspider"),
    :start_from =>  '',
    :db_string  =>  File.join(@path, "weibo.sqlite"),
    :cookie_path=>  File.join(@path, 'cookies'),
    :spider     =>  'Voyager.NO1'
  }

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each{ |k, v| config[k.to_sym] = v if @valid_config_keys.include? k.to_sym }
  end

  def self.check_config
    if ((not has_cookie_cache?) && config[:username].nil?)
      raise ConfigureError.new("need username.")
    end
  end

  def self.has_cookie_cache?
    File.exists? cookie_file
  end

  def self.cookie_file
    if config[:username]
      return File.join(config[:cookie_path], "#{config[:username]}.cookies")
    end

    Dir.entries(config[:cookie_path]).each do |item|
      return File.join(config[:cookie_path], item) if item.end_with? '.cookies'
    end
  end

  def self.configure_with(yaml_file)
    begin
      config = YAML::load(IO.read(yaml_file))
    rescue Errno::ENOENT
      LOG.warn("User infomation not found. Using defaults."); return
    rescue Psych::SyntaxError
      LOG.warn("configure has invalid content. Using defaults."); return
    end

    configure(config)
  end

  def self.setup_db
    @db = Sequel.connect(config[:db_string])
    
    require 'wbspider/model/page'
    require 'wbspider/model/profile'
    require 'wbspider/model/relation'
    require 'wbspider/model/weibo'
    require 'wbspider/model/dbhandler'

    create_tables(@db)
  end

  def self.config
    @config
  end

  def self.db
    @db
  end
end