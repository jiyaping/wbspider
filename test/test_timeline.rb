#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'
require 'open-uri'

class TimelineTest < Minitest::Test
  include Wbspider

  def setup
    @html_dir = File.dirname(__FILE__)
    @agent = Mechanize.new
    @agent.get("file://#{@html_dir}/local_page/timeline.html")
  end

  def test_agent_load
    assert @agent.page
  end

  def test_timeline_initalize
    pp Wbspider::TimelinePage.new(:agent=> @agent).models
  end
end