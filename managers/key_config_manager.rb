module DigYukko
  # キー設定画面の管理用マネージャ
  module KeyConfigManager
    BASE_X = 240
    BASE_Y = 100
    CURSOR_CHOICES = [
      {
        x: BASE_X,
        y: BASE_Y,
        str: '掘る・攻撃・決定',
        process: -> (args) {
          args[:manager].tmp_config.attack = KEY.pushed_keys.first
        }
      },
      {
        x: BASE_X,
        y: BASE_Y + 30 * 1,
        str: 'ジャンプ',
        process: -> (args) {
          args[:manager].tmp_config.jump = KEY.pushed_keys.first
        }
      },
      {
        x: BASE_X,
        y: BASE_Y + 30 * 2,
        str: '特殊行動',
        process: -> (args) {
          args[:manager].tmp_config.extra = KEY.pushed_keys.first
        }
      },
      {
        x: BASE_X + 20,
        y: BASE_Y + 30 * 6,
        str: '変更前に戻す',
        process: -> (args) {
          return unless KEY.push?(KEY.attack)
          args[:manager].reset_changed
        }
      },
      {
        x: BASE_X + 20,
        y: BASE_Y + 30 * 7,
        str: 'デフォルトに戻す',
        process: -> (args) {
          return unless KEY.push?(KEY.attack)
          args[:manager].tmp_config.assign(KeyConfig::DEFAULT)
        }
      },
      {
        x: BASE_X + 20,
        y: BASE_Y + 30 * 8,
        str: '確定',
        process: -> (args) {
          return unless KEY.push?(KEY.attack)
          if args[:manager].tmp_config.valid?(false)
            KEY.config.assign(args[:manager].tmp_config.to_h)
            args[:manager].go_to_next_scene(TitleScene)
          else
            DigYukko.log(:debug, 'invalid key config, cannot return to title.', self)
          end
        }
      },
      {
        x: BASE_X + 20,
        y: BASE_Y + 30 * 9,
        str: 'キャンセル',
        process: -> (args) {
          return unless KEY.push?(KEY.attack)
          args[:manager].go_to_next_scene(TitleScene)
        }
      },
    ]
    KEY_DISPLAY_POSITIONS = [
      [:attack, CURSOR_CHOICES[0][:y]],
      [:jump, CURSOR_CHOICES[1][:y]],
      [:extra, CURSOR_CHOICES[2][:y]],
    ]

    class << self
      def init(*)
        @cursor = Cursor.new(CURSOR_CHOICES)
        @before_changed = KEY.config.to_h
        @tmp_config = KeyConfig.new(@before_changed)
      end

      def tmp_config
        @tmp_config
      end

      def reset_changed
        @tmp_config.assign(@before_changed)
      end

      def update_components
        @cursor.update
      end

      def draw_components
        KEY_DISPLAY_POSITIONS.each do |sym, y|
          key_str = @tmp_config.human_readable(sym).to_s
          ::DXRuby::Window.draw_font_ex(BASE_X + 200, y, key_str, FONT[:regular])
        end
        @cursor.draw
        CURSOR_CHOICES.each do |choice|
          ::DXRuby::Window.draw_font_ex(choice[:x] + 30,
                                        choice[:y],
                                        choice[:str],
                                        FONT[:regular])
        end
      end

      def check_keys
        if KEY.pushed_y.zero?
          @cursor.exec if KEY.pushed_keys.any?
        else
          @cursor.move(KEY.pushed_y)
        end
      end

      def go_to_next_scene(next_scene_class)
        ApplicationManager.change_scene(next_scene_class.new)
      end
    end
  end
end
