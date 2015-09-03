#encoding:utf-8

module Wbspider
  HISTORY_VIEWS = []

  class BaseView
    attr_accessor :width, 
                  :height, 
                  :models,
                  :activity,
                  :curr_model,
                  :formatter,
                  :colour_models,
                  :nickname,
                  :pages

    def initalize(opts = {})
      @width          = opts[:width]  || 80
      @height         = opts[:height] || 25
      @formatter      = opts[:formatter]
      @show_header    = opts[:header] || true
      @pages          = Pages.new(:width => @width,
                                  :height => @height,
                                  :models => opts[:models],
                                  :formatter => opts[:formatter])
    end

    def header
      fill_blank("WBSPIDER").color(:black).background(:white)
    end
  end
end