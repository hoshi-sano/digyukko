module DigYukko
  module BgmManager
    include HelperMethods

    class << self
      BGM_FILE_NAMES = [
        :title,
        :dungeon,
      ]

      def init
        @list = BGM_FILE_NAMES.map { |name|
          sound = load_music(name)
          sound.predecode
          [name, sound]
        }.to_h
      end

      def play(id, loop = true)
        return if @now_playing == id
        stop if @now_playing && (@now_playing != id)
        @list[id].play(loop ? 0 : 1, 0)
        @now_playing = id
      end

      def stop
        @list[@now_playing].stop(1)
        @now_playing = nil
      end

      def load_music(name)
        path = find_file([CUSTOM_MUSIC_DIR, MUSIC_DIR], name.to_s, %w(wav ogg mp3))
        path = find_file(SOUND_DIR, 'silent', %w(wav)) unless path
        Ayame.new(path)
      end
    end
  end
  BGM = BgmManager
end
