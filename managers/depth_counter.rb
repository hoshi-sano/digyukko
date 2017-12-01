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
    end

    def draw
      ::DXRuby::Window.draw_font_ex(POSITION[:x],
                                    POSITION[:y],
                                    sprintf(STR_FORMAT, @count),
                                    FONT[:regular],
                                    OPTIONS)
    end
  end
end
