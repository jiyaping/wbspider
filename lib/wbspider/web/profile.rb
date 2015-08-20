# encoding : utf-8

module Wbspider
  class ProfilePage < WebPage
    def nextpage
      return nil
    end

    def fill_models
       @models << Wbspider::Profile.new(ext_base_info)
    end

    def ext_base_info()
      fields = {}

      @agent.page.at('.tips').next_sibling.children.each do |item|
        next if item.to_html =~ /\<br\>/

        (fields[:nickname] = $1 && next) if item.to_html.match /昵称:(.*)/
        (fields[:vipinfo]  = $1 && next) if item.to_html.match /认证信息:(.*)/
        (fields[:gender]  = $1 && next) if item.to_html.match /性别:(.*)/
        (fields[:area]  = $1 && next) if item.to_html.match /地区:(.*)/
        (fields[:vipinfo_detail]  = $1 && next) if item.to_html.match /地区:(.*)/
        (fields[:summary]  = $1 && next) if item.to_html.match /简介:(.*)/
      end

      fields[:original_id] = ext_userid(@agent.page)
      fields[:tag] = ext_tag(@agent.page)

      fields
    end

    def ext_userid(node)
      return $1 if agent.page.at('img').match /\.cn\/(\d*)\//
    end

    def ext_tag(node)
      node.search("a[href*='search/?keyword=']").inject do |_, a|
        _ += a.text
      end
    end
  end
end