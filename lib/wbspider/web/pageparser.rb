#encoding : utf-8

module Wbspider
  module PageParser
    def ext_single_weibo(node)
      fields = {}

      is_repost = node.children.size == 2
      return ext_weibo_original(node.children[0]) unless is_repost

      c_node = node.children[1]
      o_node = node.children[0]

      fields[:nickname], fields[:nick_href] = ext_nickname_href(o_node)
      fields[:userid] = user
      fields[:weibo_id] = ext_weibo_id(node)
      fields[:is_vip] = 'v' if ext_vip(o_node)
      fields[:is_donate] = 'm' if ext_donate(o_node)
      fields[:content] = ext_original_content(c_node)
      fields[:content_pic] = ext_content_pic(c_node)
      fields[:attitude_href], fields[:attitude] = ext_attitude(c_node)
      fields[:report_href], fields[:report] = ext_repost(c_node)
      fields[:comment_href], fields[:comment] = ext_comment(c_node)
      fields[:favorite_href] = ext_favorite(c_node)
      fields[:generate_by] = ext_generate_by(node)
      fields[:generate_time] = ext_generate_time(node)

      fields[:original_nickname_href], fields[:original_nickname] = ext_original_nickname(o_node)
      fields[:original_is_vip] = 'v' if ext_vip(o_node)
      fields[:original_is_donate] = 'm' if ext_donate(o_node)
      fields[:original_content] = o_node.at('.ctt').text
      fields[:original_pic] = ext_content_pic(o_node)
      fields[:original_attitude] = ext_original_attitude(o_node)
      fields[:original_repost] = ext_original_repost(o_node)
      fields[:original_comment_href], fields[:original_comment] = ext_comment(o_node)

      fields
    end

    def ext_weibo_original(node)
      fields = {}

      fields[:nickname], fields[:nick_href] = ext_nickname_href(node)
      fields[:weibo_id] = ext_weibo_id(node)
      fields[:is_vip] = 'v' if ext_vip(node)
      fields[:is_donate] = 'm' if ext_donate(node)
      fields[:content] = ext_content(node)
      fields[:content_pic] = ext_content_pic(node)
      fields[:attitude_href], fields[:attitude] = ext_attitude(node)
      fields[:report_href], fields[:report] = ext_repost(node)
      fields[:comment_href], fields[:comment] = ext_comment(node)
      fields[:favorite_href] = ext_favorite(node)
      fields[:generate_by] = ext_generate_by(node)
      fields[:generate_time] = ext_generate_time(node)

      fields
    end

    def ext_original_repost(o_node)
      value = o_node.to_html.scan(/>转发\[(\d*)\]</).first

      return value.first if not value.nil?

      0
    end

    def ext_original_attitude(node)
      value = node.to_html.scan(/>赞\[(\d*)\]</).first

      return value.first if not value.nil?

      0
    end

    def ext_weibo_id(node)
      $1 if node.attributes["id"].value.match /^M_(.*)/
    end

    def ext_original_nickname(node)
      element = node.at('.cmt a')

      return element.attributes['href'].value, element.text
    end

    def ext_page_time
      @pagetime = DateTime.now

      if agent.page.at('.b').text.match /\[(.*)\]/
        @pagetime = DateTime.strptime($1, '%m-%d %H:%M')
      end
    end

    def ext_generate_time(node)
      str = node.css("span[class='ct']").text.split("\u00A0").first

      str = str.sub('今天', DateTime.now.strftime('%m月%d日'))
      if str.match(/(\d*)分钟/)
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
      ext_weibo_status(node, 'fav')[0]
    end

    def ext_comment(node)
      ext_weibo_status(node, 'comment')      
    end

    def ext_repost(node)
      ext_weibo_status(node, 'repost')
    end

    def ext_attitude(node)
      ext_weibo_status(node, 'attitude')
    end

    def ext_weibo_status(node, type)
      element = node.at("a[href*='#{type}']")
      return unless element

      num = 0
      num = $1 if element.text.match(/\[(\d+)\]/)
      
      return element.attributes['href'].value, num
    end

    def ext_content_pic(node)
      urls = node.to_html.scan(/\[<a href="(.*)">\]/)

      urls.join(",")
    end

    def ext_original_content(node)
      content = ''
      node.children.each do |item|
        next if item.to_html.match /class="cmt"/
        break if item.to_html.match /(\/attitude\/)|(\/repost\/)|(\/comment\/)/

        content << item.to_html
      end

      content
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
      not node.at("img[alt='V']").nil?
    end

    def ext_donate(node)
      not node.at("img[alt='M']").nil?
    end

    def ext_nickname_href(node)
      element = node.at('.nk')
      return unless element

      nickname = element.text
      nick_href = element.attributes['href'].value

      return nickname, nick_href
    end
  end
end