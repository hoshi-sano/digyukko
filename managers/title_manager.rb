module DigYukko
  module TitleManager
    include HelperMethods

    class << self
      CURSOR_CHOICES = [
        {
          x: 100,
          y: 350,
          str: 'START GAME',
          process: -> (args) { args[:manager].go_to_next_scene(ActionScene) },
        },
        {
          x: 100,
          y: 400,
          str: 'KEY CONFIG',
          process: -> (args) { args[:manager].go_to_next_scene(KeyConfigScene) },
        },
      ]

      def init(*)
        @cursor = Cursor.new(CURSOR_CHOICES, ::DXRuby::C_BLACK)
        if find_file([CUSTOM_IMAGE_DIR, IMAGE_DIR], 'title', %w(png jpg))
          @bg = load_image('title')
        else
          @bg = ::DXRuby::Image.new(Config['window.width'],
                                    Config['window.height'],
                                    ::DXRuby::C_WHITE)
        end
      end

      def update_components
        @cursor.update
      end

      def draw_components
        ::DXRuby::Window.draw(0, 0, @bg)
        @cursor.draw
        CURSOR_CHOICES.each do |choice|
          ::DXRuby::Window.draw_font_ex(choice[:x] + 30,
                                        choice[:y],
                                        choice[:str],
                                        FONT[:regular],
                                        color: ::DXRuby::C_BLACK)
        end
      end

      def check_keys
        @cursor.move(KEY.pushed_y)
        @cursor.exec if KEY.push?(KEY.attack)
      end

      def go_to_next_scene(next_scene_class)
        ApplicationManager.change_scene(next_scene_class.new)
      end
    end
  end
end
