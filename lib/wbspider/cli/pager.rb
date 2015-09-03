#encoding : utf-8

module Wbspider
  class Pager
    attr_accessor :width, 
                  :height, 
                  :models, 
                  :formatter, 
                  :page_idx, 
                  :model_idx

    def initalize(opts = {})
      @width      =   opts[:width]  || (80 - 1)
      @height     =   opts[:height] || 25
      @models     =   opts[:models]
      @formatter  =   opts[:formatter]

      @page_idx   =   0
      @model_idx  =   0
    end

    def show(page_id = nil)
      page_id ||= @page_idx
      reuslt    = []

      pages[page_id].each_with_index do |item, idx|
        ctt = item[:content]
        # if current is select model, then modify the background
        ctt = @formatter.select_model(ctt) if @model_idx == idx
        result << ctt
      end

      reuslt
    end

    def next_page
      return if @page_idx > total_page

      @page_idx += 1
      @model_idx = 0

      show
    end

    def previous_page
      return if @page_idx < 1

      @page_idx -= 1
      @model_idx = 0
      
      show
    end

    def next_model
      return next_page if @model_idx > curr_page_size

      @model_idx += 1

      show
    end

    def previous_model
      return previous_model if @model_idx < 1

      @model_idx -= 1

      show
    end

    def total_page
      pages.size
    end

    def curr_page_size
      pages[@page_idx].size
    end

    def pages
      return @pages if @pages

      @pages      = []
      curr_height = 0
      curr_page   = []
      @models.each_with_index do |model, idx|
        if curr_height >= @height
          curr_height = 0
          @pages      << curr_page
          curr_page   = []
        end

        lines       = get_lines(model)
        curr_height += lines.size
        curr_page << {:model => model, 
                      :line_num => lines.size,
                      :content => @formatter.colour(model)<< fill_lines_with_empty(lines)}
      end
      @pages << curr_page if curr_page.size > 0

      @pages
    end

    def get_lines(model)
      lines = []

      split_line(formatter.lines(model))each do |line|
        lines << {:model_index=> model_index, :content=>line}  
      end

      lines
    end

    def inject_color()
    end

    def fill_lines_with_empty(lines)
      lines.size * @width - get_line_size(lines.inject(:+))
    end

    def fill_blank(str, type = :tail)
      case type
      when :tail
        str << ' ' * (@width - get_line_size(str))
      when :head
        ' ' * (@width - get_line_size(str)) << ' '
      end
    end

    def get_line_size(str)
      two_bit_width_reg = /[\u3400-\u4DB5\u4E00-\u9FA5\u9FA6-\u9FBB\uF900-\uFA2D
                          \uFA30-\uFA6A\uFA70-\uFAD9\uFF00-\uFFEF
                          \u2E80-\u2EFF\u3000-\u303F\u31C0-\u31EF]/

      str.size + str.gusb(two_bit_width_reg, '').size
    end

    def split_line(str)
      lines = []

      line = ''
      str.chars.each do |c|
        if get_line_size(line) >= @width
          line = ''
          lines << line
        end

        line += c
      end

      lines
    end
  end
end