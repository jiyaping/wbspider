#encoding : utf-8

module Wbspider
  class Agent
    @@queue_len = 100

    attr_accessor :config, 
                  :qdone, 
                  :qtodo, 
                  :agent,
                  :userid,
                  :ssl

    def initialize(opts={})
      @config = opts
      @qdone  = QueueDone.new(QueueDone, @@queue_len)
      @qtodo  = QueueTodo.new(QueueTodo, @@queue_len * 2)
      @agent  = Mechanize.new

      #set proxy for debug
      @agent.set_proxy '127.0.0.1', 8888

      change_agent
      login_muti_times
    end

    def timeline
      goto(:timeline)
      TimelinePage.new(@config.merge :agent=>@agent)
    end

    def index(param={})
      goto(:index, fill_param(param))
      WeiboPage.new(@config.merge :agent=>@agent)
    end

    def fans(param={})
      goto(:fans, fill_param(param))
      FansPage.new(@config.merge :agent=>@agent)
    end

    def follow(param={})
      goto(:follow, fill_param(param))
      FollowPage.new(@config.merge :agent=>@agent)
    end

    def fill_param(param)
      param[:userid]   ||= @userid
      param[:page_num] ||= 1 #if param.keys.index :page_num

      param
    end

    def login_muti_times(times = 3)
      begin
        login
        times -= 1
      end while not login? and times > 1

      # login success and then init userid
      init_userid
    end

    def init_userid
      @userid ||= $1 if @agent.page.at('.tip2').at('a')[:href].match /\/(\d+)\//
    end

    def login(force=false)
      cookie_file = File.join(@config[:cookie_path], "#{@config[:username]}.cookies")

      if(File.exists?(cookie_file) && (not force))
        login_with_cookies(cookie_file)
      else
        login_with_username(cookie_file)
      end
    end

    def login?
      @agent.page.at('.nl') != nil
    end

    def login_with_username(cookie_file)
      page = goto(:login)

      page.form.fields[0].value = @config[:username]
      page.form.fields[1].value = @config[:password]

      @agent.submit page.form, page.form.buttons.first
      save_cookie(cookie_file)
    end

    def login_with_cookies(cookie_file)
      load_cookie(cookie_file)

      goto(:timeline)
    end

    def save_cookie(path)
      Dir.mkdir File.dirname(path) unless Dir.exists? File.dirname(path)

      @agent.cookie_jar.save(path)
    end

    def load_cookie(path)
      @agent.cookie_jar.load(path)
    end

    def change_agent
      agent_arr = [
                    'iPhone',
                    'iPad',
                    'Android'
                    ]

      @agent.user_agent_alias = agent_arr[rand(agent_arr.size)]
    end

    def goto(page_flag, param=nil)
      param ||= fill_param({})

      case page_flag
      when :timeline
        @agent.get(fullpath('/'))
      when :index
        # tricky for self index. with /profile suffix
        cxt_path = "%{userid}"
        cxt_path = "%{userid}/profile" if param[:userid] == @userid
        @agent.get(fullpath(cxt_path, param))
      when :login
        @agent.get(fullpath("login.weibo.cn/login/"))
      when :fans
        @agent.get(fullpath("%{userid}/fans?page=%{page_num}", param))
      when :follow
        @agent.get(fullpath("%{userid}/follow?page=%{page_num}", param))
      else
        @agent.get(fullpath("/"))
      end
    end

    def fullpath(context_path, param={})
      prefix = 'http://'
      prefix = 'https://' if @ssl

      #handler login page
      return File.join(prefix, context_path) if context_path == 'login.weibo.cn/login/'

      File.join(prefix, 'weibo.cn' , context_path % param)
    end
  end
end