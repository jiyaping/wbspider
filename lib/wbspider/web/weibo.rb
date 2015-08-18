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
  end
end