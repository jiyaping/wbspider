# encoding:utf-8

require 'mechanize'
require 'yaml'
require 'sequel'
require 'date'
require 'logger'

require 'wbspider/quene'
require 'wbspider/todo'
require 'wbspider/dones'
require 'wbspider/agent'
require 'wbspider/version'

require 'wbspider/web/webpage'
require 'wbspider/web/follow'
require 'wbspider/web/profile'
require 'wbspider/web/webpage'
require 'wbspider/web/weibo'

require 'wbspider/model/page'

module Wbspider
  class LoginError < StandardError; end
end