module DigYukko
  module BgmManager
    include HelperMethods

    class << self
      BGM_FILE_NAMES = [
        :title,
        :dungeon,
      ]

      def init
        @list = {}
        BGM_FILE_NAMES.each { |name| add(name) }
      end

      def add(name)
        return false if @list.key?(name)
        sound = load_music(name)
        sound.predecode
        @list[name] = sound
        true
      end

      def play(id, loop = true)
        return if @now_playing == id
        stop if @now_playing && (@now_playing != id)
        DigYukko.log(:debug, "start play BGM, id=[#{id}] loop=[#{loop}]")
        @list[id].play(loop ? 0 : 1, 0)
        @now_playing = id
      end

      def stop
        DigYukko.log(:debug, "stop play BGM, id=[#{@now_playing}]")
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
