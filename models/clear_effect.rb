module DigYukko
  class ClearEffect
    POSITION = { x: 350, y: 100 }
    OPTIONS = {
      color: ::DXRuby::C_CYAN,
      edge: true,
      edge_color: ::DXRuby::C_WHITE,
    }
    MESSAGE = 'GAME CLEAR !'

    def initialize
      BGM.stop
      SE.play(:fanfare)
    end

    def update
    end

    def draw
      # TODO: フォントや表示位置の調整 (画像の方がいいかも？)
      ::DXRuby::Window.draw_font_ex(POSITION[:x],
                                    POSITION[:y],
                                    MESSAGE,
                                    FONT[:regular],
                                    OPTIONS)
    end

    def finished?
      if SE.finished?(:fanfare)
        ApplicationManager.change_scene(StoryScene.new(:ending, ResultScene, :success))
        true
      else
        false
      end
    end
  end
end
