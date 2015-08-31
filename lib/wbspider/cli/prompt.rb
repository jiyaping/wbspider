#encoding:utf-8

module Wbspider
  class Prompt
    attr_accessor :width, 
                  :height, 
                  :models, 
                  :activity,
                  :curr_idx,
                  :page_size,
                  :colorful

    def initalize(opts={})
      @models     = opts[:models]
      @width      = opts[:width]  || 80
      @height     = opts[:height] || 25
      @colorful   = Colorful.new(opts[:formater])

      @lines      = @models.inject(0)
      @curr_idx   = 0
      @activity   = 0
    end

    def next_node
      return if @models.size <= @activity

      @activity += 1
    end

    def previous_node
      return if @activity <= 0

      @activity -= 1
    end

    def next_page

    end

    def previous_page
    end

    def header
    end

    def footer
    end
  end
end