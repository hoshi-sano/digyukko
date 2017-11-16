module DigYukko
  module TitleManager
    class << self
      CURSOR_CHOICES = [
        { x: 200, y: 300, process: -> (args) { args[:manager].go_to_next_scene } },
        { x: 200, y: 350, process: -> (args) { puts "pushed #{args}" } },
      ]
      CHOICE_STRINGS = [
        { x: 230, y: 300, str: 'START GAME' },
        { x: 230, y: 350, str: 'KEY CONFIG' },
      ]

      def init(*)
        @cursor = Cursor.new(CURSOR_CHOICES)
        # TODO: タイトル画面背景画像に差し替える
        @bg = ::DXRuby::Image.new(Config['window.width'],
                                  Config['window.height'],
                                  ::DXRuby::C_BLUE)
      end

      def update_components
        @cursor.update
      end

      def draw_components
        ::DXRuby::Window.draw(0, 0, @bg)
        @cursor.draw
        CHOICE_STRINGS.each do |choice|
          ::DXRuby::Window.draw_font_ex(choice[:x], choice[:y], choice[:str], FONT[:regular])
        end
      end

      def check_keys
        @cursor.move(KEY.pushed_y)
        # TODO: カーソルの位置によって次のシーンを変える
        @cursor.exec if KEY.push?(KEY.attack)
      end

      def go_to_next_scene
        next_scene = ActionScene.new
        ApplicationManager.change_scene(next_scene)
      end
    end
  end
end
