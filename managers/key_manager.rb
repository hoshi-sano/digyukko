module DigYukko
  # TODO: 現状DXRubyのキー定数を直に返しているが、ゆくゆくは
  #       キーコンフィグでユーザが設定した任意のものを返せる
  #       ようにする
  module KeyManager
    class << self
      def push?(key)
        ::DXRuby::Input.key_push?(key)
      end

      def down?(key)
        ::DXRuby::Input.key_down?(key)
      end

      def down_keys
        ::DXRuby::Input.keys
      end

      def jump
        ::DXRuby::K_Z
      end

      def attack
        ::DXRuby::K_X
      end

      def left
        ::DXRuby::K_LEFT
      end

      def right
        ::DXRuby::K_RIGHT
      end
    end
  end
  # alias
  KEY = KeyManager
end
