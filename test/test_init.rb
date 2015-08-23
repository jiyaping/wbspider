gem "minitest"
require 'minitest/autorun'
require 'wbspider'

module Minitest
  Wbspider.setup_db(File.join(Dir.home, 'wbspider', 'wbspider-test.sqlite'))
end