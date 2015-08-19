#encoding : utf-8

gem "minitest"
require 'minitest/autorun'
require 'wbspider'
require 'open-uri'

class PageParser_Test < Minitest::Test
  include Wbspider::PageParser

  def setup
    @original = Nokogiri::HTML(open('test/original_weibo.html'), nil, 'UTF-8').at("div[id*='M_']")
    @repost = Nokogiri::HTML(open('test/repost_weibo.html'), nil, 'UTF-8').at("div[id*='M_']")
    @timeline = Nokogiri::HTML(open('test/timeline_weibo.html'), nil, 'UTF-8').at("div[id*='M_']")
    @timeline_repost = Nokogiri::HTML(open('test/timeline_repost.html'), nil, 'UTF-8').at("div[id*='M_']")
  end

  def test_timeline_ext_nickname_href
    assert_equal ['楚天都市报', 'http://weibo.cn/ctdsw?vt=4'], ext_nickname_href(@timeline)
  end

  def test_timeline_ext_donate
    refute ext_donate(@timeline)
  end

  def test_timeline_ext_vip
    assert ext_vip(@timeline)
  end

  def test_timeline_ext_content
    assert ext_content(@timeline)
  end

  def test_timeline_ext_content_pic
    assert_equal '', ext_content_pic(@timeline)
  end

  def test_timeline_ext_favorite
    assert_equal 'http://weibo.cn/fav/addFav/Cwz9EFj9m?rl=0&vt=4&st=6956bb',
                  ext_favorite(@timeline)
  end

  def test_timeline_ext_comment
    assert_equal ['http://weibo.cn/comment/Cwz9EFj9m?uid=1720962692&rl=0&gid=10001&vt=4#cmtfrm', '3'],
                 ext_comment(@timeline)
  end

  def test_timeline_ext_repost
    assert_equal ['http://weibo.cn/repost/Cwz9EFj9m?uid=1720962692&rl=0&gid=10001&vt=4','2'],
                  ext_repost(@timeline)
  end

  def test_timeline_ext_attitude
    assert_equal ['http://weibo.cn/attitude/Cwz9EFj9m/add?uid=1741341313&rl=0&gid=10001&vt=4&st=6956bb','1'],
                  ext_attitude(@timeline)
  end

  def test_timeline_ext_weibo_id
    assert_equal "Cwz9EFj9m", ext_weibo_id(@timeline)
  end

  def test_timeline_ext_generate_by
    assert_equal '来自微博 weibo.com', ext_generate_by(@timeline)
  end

  def test_timeline_ext_generate_time_1
    @pagetime = DateTime.now
    @node = Nokogiri::HTML::DocumentFragment.parse <<-EOHTML
    <span class="ct">今天 16:07&nbsp;来自微博 weibo.com</span>
  EOHTML
    
    assert_equal "#{@pagetime.strftime('%m月%d日')} 16:07",
                  ext_generate_time(@node).strftime('%m月%d日 %H:%M')
  end

  def test_timeline_ext_generate_time_2
    @pagetime = DateTime.now
    @node = Nokogiri::HTML::DocumentFragment.parse <<-EOHTML
    <span class="ct">08月18日 15:02&nbsp;来自微博 weibo.com</span>
  EOHTML

    assert_equal "08月18日 15:02",
                  ext_generate_time(@node).strftime('%m月%d日 %H:%M')
  end

  def test_timeline_ext_generate_time_3
    @pagetime = DateTime.now
    @node = Nokogiri::HTML::DocumentFragment.parse <<-EOHTML
    <span class="ct">10分钟前&nbsp;来自微博 weibo.com</span>
  EOHTML
    
    assert_equal (@pagetime + Rational(10, 1440)).strftime('%m月%d日 %H:%M'),
                  ext_generate_time(@node).strftime('%m月%d日 %H:%M')
  end

  def test_ext_weibo_original
    assert ext_weibo_original(@timeline)
  end

  def test_repost_ext_weibo_content
    c_node = @repost.children[1]

    assert ext_original_content(c_node)
  end 

  def test_ext_weibo_repost
    assert ext_single_weibo(@repost)
  end

  def test_ext_timeline_repost
    @pagetime = DateTime.now
    assert ext_single_weibo(@timeline_repost)
  end

  def user
    "testttttttttt"
  end
end