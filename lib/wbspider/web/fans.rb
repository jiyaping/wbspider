# encoding : utf-8

module Wbspider
  class FansPage < WebPage
    def nextpage
      return nil if last?

      next_path = "#{user}/fans?page=#{@page_idx}"
      @agent.get(fullpath(next_path))

      return FansPage.new :agent=> @agent
    end

    def nickname
      node = agent.page.at("div[class='ut']")

      if(node)
        node.text.sub('的粉丝', '')
      end
    end
  end
end