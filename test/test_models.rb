#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class ModelsTest < Minitest::Test
  def test_page_initialize
    assert Wbspider::Page.create(:original_id=>'22',
                              :nickname=>'222',
                              :url=>'232',
                              :page_content=>'3232',
                              :page_num=>'323',
                              :page_type=>'32',
                              :spiderid=>'323',
                              :page_time=>'323',
                              :parsered=>'323')
  end

  def test_weibo_initalize
    assert Wbspider::Weibo.create(:weibo_id=> "asdfgh")
  end

  def test_profile_initalize
    assert Wbspider::Profile.create(:original_id=> 'asdfgh')
  end

  def test_relation_initalize
    assert Wbspider::Relation.create(:user_id=> 'asdfgh')
  end

  def teardown
    Wbspider::Page.delete_all
    Wbspider::Weibo.delete_all
    Wbspider::Profile.delete_all
    Wbspider::Relation.delete_all
  end
end

