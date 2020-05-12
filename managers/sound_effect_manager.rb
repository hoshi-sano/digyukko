module DigYukko
  module SoundEffectManager
    include HelperMethods

    class << self
      SE_FILE_NAMES = [
        :break,    # ブロック破壊音
        :charged,  # 特技パワーチャージ音
        :extra,    # 特技発動音
        :failed,   # 失敗音
        :fanfare,  # ファンファーレ
        :fatal,    # 致命傷
        :got_item, # アイテム取得音
        :jump,     # ジャンプ
        :ok,       # 決定音
        :pre_bomb, # 爆発前兆音
        :power_up, # パワーアップ音
        :success,  # クリア音
      ]

      def init
        @list = {}
        SE_FILE_NAMES.each { |name| add(name) }
      end

      def add(name)
        return false if @list.key?(name)
        sound = load_sound(name)
        sound.predecode
        @list[name] = sound
        true
      end

      def play(id)
        @list[id].play(1, 0)
      end

      def finished?(id)
        @list[id].finished?
      end

      def load_sound(name)
        path = find_file([CUSTOM_SOUND_DIR, SOUND_DIR], name.to_s, %w(wav ogg mp3))
        path = find_file(SOUND_DIR, 'silent', %w(wav)) unless path
        Ayame.new(path)
      end
    end
  end
  SE = SoundEffectManager
end
