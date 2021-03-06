# encoding : utf-8

module Wbspider
  class FollowPage < WebPage
    attr_accessor :userid, :usernick

    def initialize(opts={})
      super(opts)
      @userid = ext_userid
      @usernick = nickname
    end

    def nextpage
      return if last?

      next_path = "#{user}/follow?page=#{@page_idx}"
      @agent.get(fullpath(next_path))

      return FollowPage.new :agent=> @agent
    end

    def nickname
      node = @agent.page.at("div[class='ut']")

      if(node)
        node.text[0...node.text.index('关注的人')]
      end
    end
    
    def fill_models
      @agent.page.search("table").each do |node|
        @models<< Relation.new(ext_single_follow(node))
      end
    end

    def ext_single_follow(node)
      fields = {}

      fields[:user_id]        =   ext_userid
      fields[:user_nick]      =   nickname
      fields[:follower_id]    =   ext_follow(node)
      fields[:follower_nick]  =   ext_follow_nick(node)

      fields
    end

    def ext_userid
      return $1 if @agent.page.at("a[href*='/fans']")[:href].match /(\d+)/
    end

    def ext_follow(node)
      return $1 if node.search("td").at("a[href*='attention']")[:href].match /uid=(\d+)/
    end

    def ext_follow_nick(node)
      node.search("td").last.children[0].text
    end
  end
end