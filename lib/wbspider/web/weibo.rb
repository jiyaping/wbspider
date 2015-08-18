# encoding : utf-8

module Wbspider
  class WeiboPage < WebPage
    def nextpage
      return nil if last?

      next_path = "#{user}?page=#{@page_idx}"
      @agent.get(fullpath(next_path))

      return WeiboPage.new :agent=> @agent
    end

    def nickname
      agent.page.at("div[class='ut']").children[0]
    end

    def fill_models
      nodes = @agent.page.search("div[class='c',id*='M_']")

      nodes.each do |node|
        models << Weibo.new(fill_single_model(node))
      end
    end

    def ext_single_weibo(node)
      fields = {}

      is_repost = node.children.size == 2
      if(not is_repost)
        return ext_weibo_original(node.children[0])
      end

      c_node = node.children[1]
      o_node = node.children[0]

      fields[:nickname], fields[:nick_href] = ext_nickname_href(o_node)
      fields[:userid] = user
      fields[:weibo_id] = 
      fields[:is_vip] = 'v' if ext_vip(o_node)
      fields[:is_donate] = 'm' if ext__donate(o_node)
      fields[:content] = ext_content(c_node)
      fields[:content_pic] = ext_content_pic(c_node)
      fields[:attitude], fields[:attitude_href] = ext_attitude(c_node)
      fields[:report], fields[:report_href] = ext_report(c_node)
      fields[:comment], fields[:comment] = ext_comment(c_node)
      fields[:favorite_href] = ext_favorite(c_node)

      fields[:original_nickname], fields[:original_nickname_href] = ext_original_nickname(o_node)
      fields[:original_is_vip] = 'v' if ext_vip(o_node)
      fields[:original_is_donate] = 'm' if ext__donate(o_node)
      fields[:original_content] = o_node.at('.ctt').text
      fields[:original_pic] = ext_content_pic(o_node)
      fields[:original_attitude] = ext_original_attitude(o_node)
      fields[:original_repost] = ext_original_repost(o_node)
      fields[:original_comment] = ext_comment(o_node)

      fields
    end

    def ext_weibo_original(node)
      fields = {}

      fields[:nickname], fields[:nick_href] = ext_nickname_href(node)
      fields[:is_vip] = 'v' if ext_vip(node)
      fields[:is_donate] = 'm' if ext__donate(node)
      fields[:content] = ext_content(node)
      fields[:content_pic] = ext_content(node)
      fields[:attitude], fields[:attitude_href] = ext_attitude(node)
      fields[:report], fields[:report_href] = ext_report(node)
      fields[:comment], fields[:comment] = ext_comment(node)
      fields[:favorite_href] = ext_favorite(node)

      fields
    end

    def ext_original_repost(o_node)
      value = node.to_html.scan(/>转发\[(\d*)\]</).first

      return value.first if not value.nil?

      0
    end

    def ext_original_attitude(node)
      value = node.to_html.scan(/>赞\[(\d*)\]</).first

      return value.first if not value.nil?

      0
    end

    def ext_original_nickname(node)
      element = node.at('.cmt a')

      element.attributes[:href], element.text
    end

    def ext_page_time
      @pagetime = DateTime.now

      if agent.page.at('.b').text.match /\[(.*)\]/
        @pagetime = DateTime.strptime($1, '%m-%d %H:%M')
      end
    end

    def ext_generate_time(node)
      str = node.at("span[class='ct']").text.split("\u00A0").first

      str = str.sub('今天', DateTime.now.strftime('%m月%d日'))

      if str.match(/(\d*)分钟之前/)
        @pagetime + Rational($1.to_i, 1440)
      elsif str =~ /\d{2}:\d{2}/
        DateTime.strptime(str, '%m月%d日 %H:%M')
      else
        @pagetime
      end
    end

    def ext_generate_by(node)
      node.at("span[class='ct']").text.split("\u00A0")[1]
    end

    def ext_favorite(node)
      ext_weibo_status(node, 'fav')
    end

    def ext_comment(node)
      ext_weibo_status(node, 'comment')      
    end

    def ext_report(node)
      ext_weibo_status(node, 'report')
    end

    def ext_attitude(node)
      ext_weibo_status(node, 'attitude')
    end

    def ext_weibo_status(node, type)
      element = node.at("a[href*='#{type}']")

      num_arr = element.text.scan(/[(\d*)]/)
      num = num_arr.first[0] if num_arr.size > 0
      element.attitudes[:href], num
    end

    def ext_content_pic(node)
      urls = node.to_html.scan(/[<a href="(.*)">]/)

      urls.join(",")
    end

    def ext_content(node)
      elements = node.search("span[class='ctt']")

      content = ''
      if(elements.size == 0)
        node.children.each do |item|
          break if item.name = 'a' && item.text =~ /\[\d*\]/

          content += item.to_html
        end
      else
        content = elements.first.to_html
      end

      content
    end

    def ext_vip(node)
      not node.search("img[alt='V']").nil?
    end

    def ext__donate(node)
      not node.search("img[alt='M']").nil?
    end

    def ext_nickname_href(node)
      element = node.at('.nk')

      nickname = element.text
      nick_href = element.attributes['href'].value

      nickname, nick_href
    end
  end
end