# encoding : utf-8

module Wbspider
  class FansPage < FollowPage
    def nextpage
      return if last?

      next_path = "#{user}/fans?page=#{@page_idx}"
      @agent.get(fullpath(next_path))

      return FansPage.new :agent=> @agent
    end

    def nickname
      node = @agent.page.at("div[class='ut']")

      if(node)
        node.text[0...node.text.index('的粉丝')]
      end
    end

    def ext_single_follow(node)
      fields = {}

      fields[:user_id]        =   ext_follow(node)
      fields[:user_nick]      =   ext_follow_nick(node)
      fields[:follower_id]    =   ext_userid
      fields[:follower_nick]  =   nickname
      
      fields
    end
  end
end