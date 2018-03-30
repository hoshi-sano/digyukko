module DigYukko
  class ClearEffect
    POSITION = { x: 100, y: Config['window.height'] / 2 }
    OPTIONS = {
      color: ::DXRuby::C_CYAN,
      edge: true,
      edge_color: ::DXRuby::C_WHITE,
    }
    MESSAGE = 'GAME CLEAR !'

    def initialize
      @count = 0
      # TODO: クリア音楽の再生開始
    end

    def update
      @count += 1
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
      # TODO: TTLではなくクリア音楽再生完了でfinishするようにする
      if @count > 150
        # TODO: エンドロール後はリザルト画面に遷移するようにする
        ApplicationManager.change_scene(StoryScene.new(:ending, TitleScene))
        true
      else
        false
      end
    end
  end
end
