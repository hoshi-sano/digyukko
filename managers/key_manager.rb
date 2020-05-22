module DigYukko
  module KeyManager
    class << self
      def init
        ::DXRuby::Input.set_repeat(Config['key_interval'], Config['key_interval'])
        # 本アプリケーションではパッドも含めたキーコンフィグ機能
        # があるため、DXRubyが提供するキーとパッドの関連付けは
        # リセットする
        (0..15).each do |n|
          p_code = ::DXRuby.const_get("P_BUTTON#{n}")
          ::DXRuby::Input.set_config(p_code, nil)
        end
        @config = KeyConfig.load_user_settings
        @config.valid?
      end

      def config
        @config
      end

      # KeyManagerはキー操作とパッド操作を統合して判定するため、
      # パッドの→とキーコードが被るESCが同じものとして判定されて
      # しまう。そのためESCは独立したメソッドで判定を行う。
      def esc_down?
        ::DXRuby::Input.key_down?(::DXRuby::K_ESCAPE)
      end

      def push?(keys)
        Array(keys).any? do |key|
          begin
            ::DXRuby::Input.key_push?(key) || ::DXRuby::Input.pad_push?(key)
          rescue ::DXRuby::DXRubyError
            false
          end
        end
      end

      def down?(keys)
        Array(keys).any? do |key|
          begin
            ::DXRuby::Input.key_down?(key) || ::DXRuby::Input.pad_down?(key)
          rescue ::DXRuby::DXRubyError
            false
          end
        end
      end

      def x
        ::DXRuby::Input.x
      end

      def y
        ::DXRuby::Input.y
      end

      def pushed_y
        (push?(up) || push?(down)) ? ::DXRuby::Input.y : 0
      end

      def down_keys
        ::DXRuby::Input.keys
      end

      def pushed_keys
        KeyConfig::TABLE.values.select do |key_value|
          begin
            ::DXRuby::Input.key_push?(key_value) ||
              ::DXRuby::Input.pad_push?(key_value)
          rescue ::DXRuby::DXRubyError
            false
          end
        end
      end

      def jump
        @config.jump
      end

      def attack
        @config.attack
      end

      def extra
        @config.extra
      end

      def up
        [::DXRuby::K_UP, ::DXRuby::P_UP]
      end

      def down
        [::DXRuby::K_DOWN, ::DXRuby::P_DOWN]
      end

      def left
        [::DXRuby::K_LEFT, ::DXRuby::P_LEFT]
      end

      def right
        [::DXRuby::K_RIGHT, ::DXRuby::P_RIGHT]
      end

      def space
        ::DXRuby::K_SPACE
      end
    end
  end
  # alias
  KEY = KeyManager
end
