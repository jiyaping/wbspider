#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'
require 'open-uri'

class FansPageTest < Minitest::Test
  include Wbspider

  def setup
    @html_dir = File.dirname(__FILE__)
    @agent = Mechanize.new
    @agent.get("file://#{@html_dir}/local_page/fans.html")
  end

  def test_agent_load
    assert @agent.page
  end

  def test_fans_page_initalize
    assert Wbspider::FansPage.new(:agent=> @agent).models
  end

  def test_fans_store
    fans = Wbspider::FansPage.new(:agent=> @agent)
    fans.model_save

    assert_equal fans.models.size, Wbspider::Relation.count
  end

  def test_fans_page_store
    fans = Wbspider::FansPage.new(:agent=> @agent)
    fans.page_save

     assert_equal 1, Wbspider::Page.count
  end

  def teardown
    Wbspider::Relation.delete_all
    Wbspider::Page.delete_all
  end
end