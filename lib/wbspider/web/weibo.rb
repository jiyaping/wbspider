# encoding : utf-8

module Wbspider
  class WeiboPage < WebPage
    include Wbspider::PageParser

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
  end
end