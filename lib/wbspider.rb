# encoding:utf-8

require 'mechanize'
require 'yaml'
require 'active_record'

require 'wbspider/queue'
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

require 'wbspider/model/page'
require 'wbspider/model/profile'
require 'wbspider/model/relation'
require 'wbspider/model/weibo'
require 'wbspider/model/done'
require 'wbspider/model/migration'

module Wbspider
  class WbspiderError < StandardError; end
  class ConfigureError < WbspiderError; end
  class LoginError < WbspiderError; end

  @home = File.join(Dir.home, 'wbspider')
  Dir.mkdir(@home) unless Dir.exists?(@home)

  # default config
  @config = {
    :username   =>  nil,
    :password   =>  nil,
    :path       =>  @home,
    :start_from =>  '',
    :db_string  =>  File.join(@home, "weibo.sqlite"),
    :cookie_path=>  File.join(@home, 'cookies'),
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

  def self.setup_db(str=config[:db_string])
    ActiveRecord::Base.establish_connection(
      adapter:  "sqlite3",
      database: str
    )

    create_tables
  end

  def self.create_tables()
    %w[Done Page Profile Relation Weibo].each do |item|
      eval("Add#{item}.up unless #{item}.table_exists?")
    end
  end

  def self.config
    @config
  end

  def self.db
    @db
  end

  def self.home
    @home
  end
end