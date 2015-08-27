#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'
require 'open-uri'

class ProfilePageTest < Minitest::Test
  def setup
    @html_dir = File.dirname(__FILE__)
    @agent = Mechanize.new
    @agent.get("file://#{@html_dir}/local_page/profile.html")
  end

  def test_profile_page_initalize
    assert Wbspider::ProfilePage.new(:agent=> @agent)
  end
end