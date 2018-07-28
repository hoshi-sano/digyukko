module DigYukko
  class DepthCounter
    attr_accessor :count

    POSITION = { x: 10, y: 10 }
    STR_FORMAT = 'DEPTH: %06d'
    OPTIONS = {
      color: ::DXRuby::C_WHITE,
      edge: true,
      edge_color: ::DXRuby::C_BLACK,
    }

    def initialize
      @count = 1
      update_count_str
      @stop = false
    end

    def update_count_str
      @count_str = sprintf(STR_FORMAT, @count)
    end

    def count_up(val)
      return if @stop
      @count += val
      update_count_str
    end

    def draw
      ::DXRuby::Window.draw_font_ex(POSITION[:x],
                                    POSITION[:y],
                                    @count_str,
                                    FONT[:regular],
                                    OPTIONS)
    end

    def stop!
      @stop = true
    end
  end
end
