# encoding : utf-8

module Wbspider
  class WebPage
    attr_accessor :agent, 
                  :page_idx,
                  :total_page,
                  :ssl,
                  :spiderid,
                  :page2db,
                  :model2db,
                  :models,
                  :pagetime

    def initialize(opts={})
      @agent    = opts[:agent]
      @ssl      = opts[:ssl]      || false
      @spiderid = opts[:spiderid] || 'Voyager.NO1'
      @page2db  = opts[:page2db]  || false
      @model2db = opts[:model2db] || false 

      @page_idx, @total_page = get_page_size
      @models   = []
      @pagetime = pagetime

      fill_models
      page_save  if page2db
      model_save if model2db
    end

    def model_save
      @models.each do |models|
        models.save
      end
    end

    def page_save
      (Page.new do |p|
        p.original_id =   user
        p.nickname    =   nickname
        p.url         =   @agent.page.uri
        p.page_content=   @agent.page.parser.to_html
        p.page_num    =   @page_idx
        p.page_type   =   2
        p.spiderid    =   @spiderid
        p.page_time   =   DateTime.now
      end).save
    end

    def fullpath(href)
      prefix = "http://weibo.cn"
      if ssl
        prefix = "https://weibo.cn"
      end

      File.join(prefix, href)
    end

    def get_page_size
      node = agent.page.at('#pagelist form div')
      return 1, 1 unless node
      text = node.children.last.text

      return $1, $2 if text.match /(\d*)\/(\d*)/
    end

    def user
      userid = $1 if agent.page.uri.to_s.match /\/(\d+)\/?/

      return userid
    end

    def nickname; end

    def fill_models; end

    def first?
      @page_idx == 1
    end

    def last?
      @page_idx == @total_page
    end

    def info
      "#{@page_idx} #{@total_page} #{@spiderid}"
    end

    def pagetime
      time_str = $1 if @agent.page.at('.b').text.match /\[(.*)\]/

      if time_str
        DateTime.strptime(time_str, '%m-%d %H:%M')
      else
        DateTime.now
      end
    end
  end
end