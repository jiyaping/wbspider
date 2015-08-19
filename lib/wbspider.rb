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
end