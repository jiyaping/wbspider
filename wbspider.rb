# encoding : utf-8

require 'mechanize'
require 'sequel'
require 'yaml'

module Wbspider
  #@db = Sequel.connect("sqlite://test.sqlite")
  #@db = Sequel.connect("mysql://root:1234567@127.0.0.1/wb")

  def self.db
    @db
  end

  def self.setup_tables
    @db.create_table? :pages do
      primary_key :id
      String      :original_id
      String      :nickname
      String      :url
      String      :page_content, :text=> true
      Integer     :page_num
      Integer     :page_type  #1. weibos 2. profiles 3.followers 4.fans
      String      :spiderid
      DateTime    :page_time
      Integer     :parsered
    end

    @db.create_table? :dones do
      primary_key :id
      String      :value
    end
  end

  setup_tables

  module Util
    def save_to_yaml(obj, path)
      File.open(path, 'wb') do |file|
        YAML.dump(obj, file)
      end
    end

    def read_from_yaml(path)
      YAML.load_file(path)
    end
  end

  module WeiboAccount
    attr_reader :accont
    @accont = {'ghenjrkakx45@163.com'=>'tttt5555',
              'fkuangwksirm1@163.com'=>'tttt5555',
              'szhifsmimc93@163.com'=>'tttt5555',
              'uzeeirvdt005@163.com'=>'tttt5555',
              'ulatatxsm3967@163.com'=>'tttt5555',
              'bwutegvaq3399@163.com'=>'tttt5555',
              'vchecrmgxu512@163.com'=>'tttt5555',
              'oduelzubh037@163.com'=>'tttt5555',
              'wchanjpdpyc94@163.com'=>'tttt5555',
              'fguuocahn9244@163.com'=>'tttt5555' }

    def get_account
      key = @account.keys[(rand @account.keys.size)]
      return key, @account[key]
    end
  end

  class Spider
    include WeiboAccount
    include Util

    attr_accessor :config, :qdone, :qtodo, :agent

    def initialize(opts={})
      @config = {
        :q_done_len => 5_000,
        :q_todo_len => 30_000,
        :start_id => 'jiyapingxx0802',
        :db => Wbspider.db,
        :site_uname => 'xxxxxx@gamil.com',
        :site_pwd => 'xxxxxpwd',
        :cookie_file => "c:\\cookie_files",
        :spiderid => "NO1",
        :carsh_cache => "c:\\carsh_cache"
      }

      @config.merge! opts

      @qdone = QueneDone.new(config[:q_done_len], config[:db])
      @qtodo = QueneTodo.new(config[:q_todo_len], config[:db])
      @agent = Mechanize.new
      @agent.set_proxy '127.0.0.1', 8118
      @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      change_user
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
        puts "status : spider name=> #{config[:spiderid]}\
              qtodo=>#{@qtodo.size} qdone=>#{@qdone.size} last=>#{@qdone.first}"

        if rand(20) % 4 == 0
          switch_user
        end
      end
    end

    def basic_info(id)
      agent.get("http://weibo.cn/#{id}")

      if original_id? id
        original_id = id
      else
        node = agent.page.at("div[class='ut']")
        return unless node 
        if node.to_html.match /\/(\d*)\/info/
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

    def login(force=false,retry_time = 3)
      retry_time.times do |round|
        login_cookie = File.join(@config[:cookie_file], "wb_cookies_#{@config[:userid]}")
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
      end
      change_user

      false
    end

    def crash_todo_save
      crash_file = File.join(@config[:carsh_cache]), @config[:spiderid])

      save_to_yaml(@config[:qtodo], crash_file)
    end

    def load_crash_todo
      crash_file = File.join(@config[:carsh_cache], @config[:spiderid])
      return unless File.exists? crash_file

      @config[:qtodo] = read_from_yaml(crash_file)
      puts "加载#{config[:qtodo].size}个id"
      File.delete(crash_file)
    end

    def change_user
      @config[:site_uname], @config[:site_pwd]= get_account
    end

    def switch_user
      puts "当前用户#{@config[:site_uname]}, 切换用户中...."
      change_user

      while not login?
        login
      end
      puts "切换成功切换到用户#{@config[:site_uname]}...."
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

    def get_ip_info
      node = @agent.get("http://ip.chinaz.com").at("span[class='info3']")
      return if node.nil?

      puts node.text
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

  class WebPage
    attr_accessor :agent, :userid, :start_page, :pages, :spiderid, :span

    def initialize(opts={})
      @agent = opts[:agent]
      @userid = opts[:userid]
      @nickname = opts[:nickname]
      @start_page = opts[:start_page]
      @spideid  = opts[:spiderid]
      @span = opts[:span] || 10
      @pages = []

      @agent.get(@start_page)
      puts "start crawling: #{@userid} - #{self.class}"
      crawling
      puts "end crawling: #{@userid}  - #{self.class}"
    end

    def saving
      @pages.each do |page|
        page.save
      end
    end

    def crawling
    end

    def span(size = 1)
      sleep rand (@span * size).to_i
    end
  end

  class WeiboPage < WebPage
    private
    def crawling
      total_page.to_i.times do |i|
        span
        page = @agent.get("http://weibo.cn/#{@userid}?page=#{i + 1}")
        puts "正在下载第#{i}页......"
        pages << Page.new do |p|
          p.original_id =   @userid
          p.nickname    =   ''
          p.url         =   "http://weibo.cn/#{@userid}?page=#{i + 1}"
          p.page_content=   page.parser.to_html
          p.page_num    =   i + 1
          p.page_type   =   1
          p.spiderid    =   @spiderid
          p.page_time   =   DateTime.now
        end
      end
    end

    def total_page
      
    end
  end

  class ProfilePage < WebPage
    def crawling
      @pages<< Page.new do |p|
          p.original_id =   @userid
          p.nickname    =   @nickname
          p.url         =   "http://weibo.cn/#{@userid}/info"
          p.page_content=   @agent.page.parser.to_html
          p.page_num    =   1
          p.page_type   =   2
          p.spiderid    =   @spiderid
          p.page_time   =   DateTime.now
        end
    end
  end

  class FansPage < WebPage
    def crawling
      total_page.to_i.times do |i|
        span
        url = "http://weibo.cn/#{@userid}/fans?page=#{i + 1}"
        page = @agent.get(url)

        pages << Page.new do |p|
          p.original_id =   @userid
          p.nickname    =   @nickname
          p.url         =   url
          p.page_content=   page.parser.to_html
          p.page_num    =   i + 1
          p.page_type   =   4
          p.spiderid    =   @spiderid
          p.page_time   =   DateTime.now
        end
      end
    end

    def total_page
      node = agent.page.at('#pagelist form div')
      return 1 unless node
      text = node.children.last.text

      return $2 if text.match /(\d*)\/(\d*)/
    end
  end

  class FollowPage < WebPage
    attr_accessor :follows

    def initialize(opts={})
      @follows = []
      super 
    end

    private

    def crawling
      total_page.to_i.times do |i|
        span
        page = @agent.get("http://weibo.cn/#{@userid}/follow?page=#{i + 1}")
        puts "正在下载第#{i}页......"
        @follows += get_follow(page)

        pages << Page.new do |p|
          p.original_id =   @userid
          p.nickname    =   @nickname
          p.url         =   "http://weibo.cn/#{@userid}/follow?page=#{i + 1}"
          p.page_content=   page.parser.to_html
          p.page_num    =   i + 1
          p.page_type   =   3
          p.spiderid    =   @spiderid
          p.page_time   =   DateTime.now
        end
      end
    end

    def get_follow(page)
      follows = []

      page.search("table img[alt='pic']").each do |item|
        follows << $1 if item[:src].match /cn\/(\d*)\//
      end

      follows
    end

    def total_page
      node = agent.page.at('#pagelist form div')
      return 1 unless node
      text = node.children.last.text

      return $2 if text.match /(\d*)\/(\d*)/
    end
  end

  class QueneTodo < Array
    attr_accessor :q_length
    attr_accessor :db

    def initialize(qlength, db)
      @q_length = qlength
      @db = db
    end

    # if the quene is full, throws the id
    def enquene(value)
      return if size >= @q_length
      return if index(value)

      push value
    end

    def dequene
      begin
        value = shift
      end while remote_get(value)

      value
    end

    private

    def remote_get(value)
      db[:dones][:value=> value]
    end

    def remote_add(value)
      db[:dones].insert(:value=> value)
    end
  end

  class QueneDone < Array
    attr_accessor :q_length
    attr_accessor :db

    def initialize(qlength, db)
      @q_length = qlength
      @db = db
    end

    def add(value)
      shift if size >= @q_length

      push value
      remote_set value
    end

    def search(value)
      result = local_get(value)
      return result if result

      result = remote_get(value)
      if result
        shift if size >= @q_length
        push result[:value]

        return result[:value]
      end

      return nil
    end

    private

    def local_get(value)
      index(value)
    end
    
    def remote_get(value)
      db[:dones][:value=> value]
    end

    def remote_set(value)
      db[:dones].insert(:value=> value)
    end
  end

  class Page < Sequel::Model
  end
end

begin
  spider = Wbspider::Spider.new(:spiderid=> ARGV[0])
  spider.start
rescue Exception => e
  puts e
ensure
  spider.crash_todo_save
end
