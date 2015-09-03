#encoding:utf-8

module Wbspider
  class Formatter
    attr_accessor :formatter

    def initalize(formatter=nil)
      @formatter ||= {
                      :inject_style => "backgroud(:white) underline",
                      :select_style => 'backgroud(:green)',
                      :weibo => {
                        :value => "%{nickname}%{content}",
                        :color => {
                          :nickname => "color(:red)",
                          :content => "color(:green)"
                        }
                      },
                      :profile => {
                        :value => "%{nickname}"
                        :color => {
                          :nickname => "color(:red)"
                        }
                      }
                    }
    end

    def colour(model)
      type = model.class.to_s.downcase.to_sym
      model_formater = @formatter[type]

      result = {}
      model_formater[:color].map do |key, value|
        result[key] = instance_eval("#{model.(key)}#{concat_color(value)}")
      end

      model_formater[:value] % result
    end

    def lines(model)
      type = model.class.to_s.downcase.to_sym
      model_formater = @formatter[type]

      model_formater[:value] % model_formater.attributes
    end

    def concat_color(color, force=true)
      color = merge_color(color) if force

      color.split(/,|\s/).map do |i|
        '.'<< i << (i.index('backgroud'))
      end.inject(:+)
    end

    def merge_color(color)
      inject_style = {}
      @formatter[:inject_style].split(/,|\s/).map do |item|
        inject_style[$1] = item if item.match /(\w)\(.+\)?/
      end

      inject_style.each do |key, value|
        color<<',' << value unless color.index(key)
      end

      color
    end

    def select_style(str)
      instance_eval("#{str}.#{@formatter[:select_style]}")
    end
  end
end