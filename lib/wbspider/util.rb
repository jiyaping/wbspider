#encoding : utf-8

module Wbspider
  module Util
    attr_accessor :log

    def log(size=20_000_000)
      log = Logger.new(get_log_file, size)
    end

    def get_log_file
      home = Wbspider.config[:path]

      if home.nil?
        home = File.join(Dir.home, "wbspider")
      end

      File.join(home, 'app.log')
    end
  end
end