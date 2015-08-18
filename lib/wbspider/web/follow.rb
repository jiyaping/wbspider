# encoding : utf-8

module Wbspider
  class FollowPage < WebPage
    def nextpage
      return nil if last?

      next_path = "#{user}/follow?page=#{@page_idx}"
      @agent.get(fullpath(next_path))

      return FollowPage.new :agent=> @agent
    end

    def nickname
      node = agent.page.at("div[class='ut']")

      if(node)
        node.text.sub('关注的人', '')
      end
    end
  end
end