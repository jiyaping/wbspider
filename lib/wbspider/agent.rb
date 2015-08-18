# encoding:utf-8

module Wbspider
  class Spider
    attr_accessor :config, :qdone, :qtodo, :agent

    def initialize(opts={})
      @config = {
        :q_done_len => 5_000,
        :q_todo_len => 30_000,
        :start_id => 'jiyaping0802',
        :db => Wbspider.db,
        :site_uname => '18938952082',
        :site_pwd => '20080802',
        :cookie_file => "c:\\",
        :spiderid => "NO1"
      }

      @config.merge! opts

      @qdone = QueneDone.new(config[:q_done_len], config[:db])
      @qtodo = QueneTodo.new(config[:q_todo_len], config[:db])
      @agent = Mechanize.new
      #debug
      #@agent.set_proxy '127.0.0.1', 8888
    end

    def start
      login
      puts "login success" if login?
      #init stack
      total_page, userid = basic_info(@config[:start_id])
      puts "#{total_page} : #{userid}"
      
      page = FollowPage.new(:agent=> @agent,
                            :userid=> userid,
                            :start_page=> "http://weibo.cn/#{userid}/follow")
      page.follows.each do |uid|
        @qtodo.enquene(uid) if not @qdone.search(uid)
      end

      puts '-'*20
      p qtodo
      puts '-'*20

      while(true)
        change_agent
        i = 1
        while not login?
          puts "第#{i+=1}尝试登录....."
          login(true)
          sleep 60
        end
        curr_userid = @qtodo.dequene
        curr_weibos = WeiboPage.new(:agent=> @agent,
                                    :userid=> curr_userid,
                                    :start_page=> "http://weibo.cn/#{curr_userid}",
                                    :spiderid=> @spiderid)
        @qdone.add curr_userid if curr_weibos.saving

        curr_follows = FollowPage.new(:agent=> @agent,
                                      :userid=> curr_userid,
                                      :start_page=> "http://weibo.cn/#{curr_userid}/follow",
                                      :spiderid=> @spiderid)
        curr_follows.saving
        curr_follows.follows.each do |uid|
          @qtodo.enquene(uid) if not @qdone.search(uid)
        end

        curr_profile = ProfilePage.new(:agent=> @agent,
                                       :userid=> curr_userid,
                                       :start_page=> "http://weibo.cn/#{curr_userid}/info",
                                       :spiderid=> @spiderid)
        curr_profile.saving

        break if(@qtodo.size == 0)
        puts "status : qtodo=>#{@qtodo.size} qdone=>#{@qdone.size} last=>#{@qdone.first}"
      end
    end

    def basic_info(id)
      agent.get("http://weibo.cn/#{id}")

      if original_id? id
        original_id = id
      else
        if agent.page.at("div[class='ut']").to_html.match /\/(\d*)\/info/
          original_id = $1
        end
      end

      node = agent.page.at('#pagelist form div')
      if node
        text = node.children.last.text
        if text.match /(\d*)\/(\d*)/
          total_page = $2
        end
      else
        total_page = 1
      end

      return total_page, original_id
    end

    def login(force=false)
      login_cookie = File.join(@config[:cookie_file], 'weibo_cn_cookies')
      if File.exists?(login_cookie) and not force
        puts "#{login_cookie} exists "
        @agent.cookie_jar.load(login_cookie)
        @agent.get("http://weibo.cn/")

        return true if login?
      end

      change_agent
      page = agent.get('http://login.weibo.cn/login/')
      page.form.fields[0].value = @config[:site_uname]
      page.form.fields[1].value = @config[:site_pwd]

      agent.submit(page.form, page.form.buttons.first)
      agent.cookie_jar.save_as login_cookie
      return true if login?

      false
    end

    def change_agent
      agent_arr = [
                  'Linux Firefox',
                  'Linux Konqueror',
                  'Linux Mozilla',
                  'Mac Firefox',
                  'Mac Mozilla',
                  'Mac Safari 4',
                  'Mac Safari',
                  'Windows Chrome',
                  'Windows IE 6',
                  'Windows IE 7',
                  'Windows IE 8',
                  'Windows IE 9',
                  'Windows Mozilla',
                  'iPhone',
                  'iPad',
                  'Android']

      @agent.user_agent_alias = agent_arr[rand(agent_arr.size)]
    end

    def login?
      @agent.page.at('.nl') != nil
    end

    def shortname(agent, userid)
      page = agent.get("http://weibo.cn/#{userid}/info")

      if (page.parser.to_html.match /:http:\/\/weibo.cn\/([^<.]*)/)
        return $1
      end
    end

    def original_id?(value)
      not value =~ /[^\d]+/
    end
  end
end