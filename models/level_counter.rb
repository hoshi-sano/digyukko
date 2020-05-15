module DigYukko
  class LevelCounter
    POSITION = { x: Config['window.width'] - 500, y: 10 }
    STR_FORMAT = 'LEVEL: %03d'
    OPTIONS = {
      color: ::DXRuby::C_WHITE,
      edge: true,
      edge_color: ::DXRuby::C_BLACK,
    }

    def draw
      ::DXRuby::Window.draw_font_ex(
        POSITION[:x],
        POSITION[:y],
        sprintf(STR_FORMAT, LevelManager.current_level),
        FONT[:regular],
        OPTIONS
      )
    end
  end

  class LevelCounterDummy
    def draw
    end
  end
end
